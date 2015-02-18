//
//  RRCVAdditions.cpp
//
//  Created by Rolandas Razma on 18/02/2015.
//  Copyright (c) 2015 Rolandas Razma. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#include "RRCVAdditions.hpp"


namespace cv {
    namespace rr {
        
        
        cv::RotatedRect findRectangle( const cv::Mat mat, const cv::Point& point ) {
            cv::Mat mask = cv::Mat::zeros(mat.rows +2, mat.cols +2, CV_8U);
            
            // Flood fill to mask
            cv::Rect fillBounds;
            uchar fillValue = 255;
            cv::floodFill(mat, mask, cv::Point(point.x, point.y), 255, &fillBounds, cv::Scalar(10), cv::Scalar(5), 4 | cv::FLOODFILL_MASK_ONLY | (fillValue << 8));

            // Find largest rect
            cv::RotatedRect largestRect;
            cv::rr::enumerate::findConvexPolys(mask, 0.03f, [&](std::vector<cv::Point> approx){
                cv::RotatedRect boundingRect = cv::minAreaRect(cv::Mat(approx));
                if( (boundingRect.size.width *boundingRect.size.height) > (largestRect.size.width *largestRect.size.height) ){
                    largestRect = boundingRect;
                }
            });

            // Move for added border
            largestRect.center.x -= 1;
            largestRect.center.y -= 1;
            
            return largestRect;
        }

        
        cv::RotatedRect findLargestRectangle( const cv::Mat mat, float maxSidesRatio, float minSidesRatio, bool inAllChannels ) {
            
            cv::RotatedRect largestRect;
            
            auto callback = [&](std::vector<cv::Point> approx){
                cv::RotatedRect boundingRect = cv::minAreaRect(cv::Mat(approx));
                
                if( (boundingRect.size.width *boundingRect.size.height) > (largestRect.size.width *largestRect.size.height) ){
                    
                    float widthHeightRatio = ((boundingRect.size.width <= boundingRect.size.height)?(float)boundingRect.size.width /(float)boundingRect.size.height:(float)boundingRect.size.height /(float)boundingRect.size.width);
                    
                    if( widthHeightRatio >= minSidesRatio && widthHeightRatio <= maxSidesRatio ){
                        largestRect = boundingRect;
                    }
                }
            };
            
            if( inAllChannels ){
                cv::rr::enumerate::findConvexPolysCT(mat, callback);
            }else{
                cv::rr::enumerate::findConvexPolys(mat, 0.02f, callback);
            }
            
            return largestRect;
            
        }
        
        
        namespace geometry {
        
            int intersect( const cv::RotatedRect& rect, const std::vector<cv::RotatedRect> squares ) {
                
                size_t squaresLength = squares.size();
                for ( int index = 0; index < squaresLength; index++ ) {
                    
                    // cv::rotatedRectangleIntersection should be used - https://github.com/Itseez/opencv/blob/master/modules/imgproc/test/test_intersection.cpp
                    // but for sake of speed this should be enaugh
                    if( intersects(rect.boundingRect(), squares[index].boundingRect()) ){
                        return index;
                    }
                }
                
                return -1;
            }
            
            bool intersects( const cv::Rect& rectA, const cv::Rect& rectB ) {
                cv::Rect intersectionRect = rectA & rectB;
                
                return ( intersectionRect.width > 0.0f || intersectionRect.height > 0.0f );
            }
            
            bool intersects( const cv::RotatedRect& rectA, const cv::RotatedRect& rectB ) {
                cv::Mat intersectingRegion;
                return !(cv::rotatedRectangleIntersection(rectA, rectB, intersectingRegion) == cv::INTERSECT_NONE);
            }
            
            void sort( std::vector<cv::RotatedRect>& squares, bool vertically ) {
                sort( squares.begin(), squares.end(), [&]( const cv::RotatedRect& lhs, const cv::RotatedRect& rhs ){
                    return ( (vertically) ? (lhs.center.y < rhs.center.y) : (lhs.center.x < rhs.center.x) );
                });
            }
            
        }
        
        
        namespace transform {
            
            void crop( cv::Mat& mat, const cv::Rect& rect ) {
                cv::Mat croppedImage;
                cv::Mat(mat, rect).copyTo(croppedImage);
                croppedImage.copyTo(mat);
            }
            
            void rotate( cv::Mat& mat, double angle, const Point2f center ){
                cv::Mat rotationMatrix = cv::getRotationMatrix2D(center, angle, 1.0f);
                int length = std::max(mat.cols, mat.rows);
                
                cv::warpAffine(mat, mat, rotationMatrix, cv::Size(length, length), cv::INTER_CUBIC);
            }
            
        }
        
        
        namespace math {
            
            double angle( const cv::Point& pt0, const cv::Point& pt1 ) {
                double dx = pt1.x -pt0.x;
                double dy = pt1.y -pt0.y;
                
                return atan2(dy, dx) ;
            }
            
            double angle( const cv::Point& pt1, const cv::Point& pt2, const cv::Point& pt0 ) {
                double dx1 = pt1.x -pt0.x;
                double dy1 = pt1.y -pt0.y;
                double dx2 = pt2.x -pt0.x;
                double dy2 = pt2.y -pt0.y;
                
                return (dx1 *dx2 + dy1 *dy2) /sqrt((dx1 *dx1 + dy1 *dy1) *(dx2 *dx2 + dy2 *dy2) + 1e-10);
            }
            
            double distance( const cv::Point& pt0, const cv::Point& pt1 ){
                double dx = (pt1.x -pt0.x);
                double dy = (pt1.y -pt0.y);
                
                return sqrt(dx *dx + dy *dy);
            }
            
        }
        
        namespace draw {

            void rectangle( cv::InputOutputArray mat, const cv::RotatedRect rotatedRect, const Scalar& color ){
                cv::Point2f rect_points[4];
                rotatedRect.points( rect_points );
                
                for ( int j = 0; j < 4; j++ ) {
                    cv::line( mat, rect_points[j], rect_points[(j+1)%4], color, 1, 8 );
                }
            }
            
            void rectangle( cv::InputOutputArray mat, const cv::Rect rect, const Scalar& color ){
                cv::rectangle(mat, rect.tl(), rect.br(), color, 1, 8, 0);
            }
            
            void rectangle( cv::InputOutputArray mat, const std::vector<cv::RotatedRect> rectangles, const Scalar& color ){
                for( int i=0; i<rectangles.size(); i++ ){
                    rectangle(mat, rectangles[i], color);
                }
            }
            
        }
        
        namespace enumerate {

            void findConvexPolys( const cv::Mat matToProcess, float accuracy, std::function<void(std::vector<cv::Point>)>callback ) {
                // Find contours
                std::vector<std::vector<cv::Point>> contours;
                cv::findContours(matToProcess.clone(), contours, cv::RETR_LIST, cv::CHAIN_APPROX_SIMPLE);
                
                for ( int contourIndex = 0; contourIndex < contours.size(); contourIndex++ ) {
                    
                    // approximate contour with accuracy proportional to the contour perimeter (good value in most cases 0.02f)
                    std::vector<cv::Point> approxCurve;
                    cv::approxPolyDP(cv::Mat(contours[contourIndex]), approxCurve, arcLength(cv::Mat(contours[contourIndex]), true) *accuracy, true);
                    
                    // test if that's convex rectangle
                    if ( approxCurve.size() == 4 && isContourConvex(approxCurve) ) {
                        
                        double maxCosine = 0;
                        for ( int edgeIndex = 2; edgeIndex < 5; edgeIndex++ ) {
                            double cosine = fabs(cv::rr::math::angle(approxCurve[edgeIndex%4], approxCurve[edgeIndex-2], approxCurve[edgeIndex-1]));
                            maxCosine = MAX(maxCosine, cosine);
                        }
                        
                        if ( maxCosine < 0.3f ){
                            callback( approxCurve );
                        }
                    }
                }
                
            }
            
            void findConvexPolysCT( const cv::Mat matToProcess, std::function<void(std::vector<cv::Point>)>callback ) {
                
                const int maxThresholdLevel = 11;
                cv::Mat grayMat(matToProcess.size(), CV_8U);
                
                for( int channelIndex = 0; channelIndex < 3; channelIndex++ ) {
                    int ch[] = {channelIndex, 0};
                    mixChannels(&matToProcess, 1, &grayMat, 1, ch, 1);

                    // try several threshold levels
                    for ( int thresholdLevel = 0; thresholdLevel < maxThresholdLevel; thresholdLevel++ ) {
                        
                        cv::Mat blendedMat;
                        
                        // Use Canny instead of zero threshold level as it helps to catch squares with gradient shading
                        if ( thresholdLevel == 0 ) {
                            // apply Canny. Take the upper threshold from slider and set the lower to 0 (which forces edges merging)
                            cv::Canny(grayMat, blendedMat, 0, 50, 5, true);
                            
                            // Dilate helps to remove potential holes between edge segments
                            cv::dilate(blendedMat, blendedMat, cv::Mat(), cv::Point(-1, -1));
                        } else {
                            blendedMat = grayMat >= (thresholdLevel +1.0f) *255.0f /maxThresholdLevel;
                        }

                        cv::rr::enumerate::findConvexPolys(blendedMat, 0.02f, callback);
                    }
                }
                
            }
            
        }
        
    }
}