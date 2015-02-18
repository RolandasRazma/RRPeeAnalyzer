//
//  RRCVAdditions.hpp
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

#ifndef __RRPeeAnalizer__RRCVAdditions__
#define __RRPeeAnalizer__RRCVAdditions__

#include <stdio.h>
#import <opencv2/opencv.hpp>


namespace cv {
    namespace rr {

        CV_EXPORTS_W cv::RotatedRect findRectangle( const cv::Mat mat, const cv::Point& point );
        CV_EXPORTS_W cv::RotatedRect findLargestRectangle( const cv::Mat mat, float maxSidesRatio = 1.0f, float minSidesRatio = 0.0f, bool inAllChannels = true );
        
        namespace geometry {
            
            CV_EXPORTS_W int intersect( const cv::RotatedRect& rect, const std::vector<cv::RotatedRect> squares );
            CV_EXPORTS_W bool intersects( const cv::Rect& rectA, const cv::Rect& rectB );
            CV_EXPORTS_W bool intersects( const cv::RotatedRect& rectA, const cv::RotatedRect& rectB );
            CV_EXPORTS_W void sort( std::vector<cv::RotatedRect>& squares, bool vertically );
            
        }

        namespace transform {
            
            CV_EXPORTS_W void crop( cv::Mat& mat, const cv::Rect& rect );
            CV_EXPORTS_W void rotate( cv::Mat& mat, double angle, const Point2f center );
            
        }
        
        namespace math {
            
            CV_EXPORTS_W double angle( const cv::Point& pt0, const cv::Point& pt1 );
            CV_EXPORTS_W double angle( const cv::Point& pt1, const cv::Point& pt2, const cv::Point& pt0 );
            CV_EXPORTS_W double distance( const cv::Point& pt0, const cv::Point& pt1 );
            
        }
        
        namespace draw {
            
            CV_EXPORTS_W void rectangle( cv::InputOutputArray mat, const cv::RotatedRect rotatedRect, const Scalar& color = cv::Scalar(255, 0, 255) );
            CV_EXPORTS_W void rectangle( cv::InputOutputArray mat, const cv::Rect rect, const Scalar& color = cv::Scalar(255, 0, 255) );
            CV_EXPORTS_W void rectangle( cv::InputOutputArray mat, const std::vector<cv::RotatedRect> rectangles, const Scalar& color = cv::Scalar(255, 0, 255) );
            
        }
        
        namespace enumerate {

            CV_EXPORTS_W void findConvexPolys( const cv::Mat matToProcess, float accuracy, std::function<void(std::vector<cv::Point>)>callback );
            CV_EXPORTS_W void findConvexPolysCT( const cv::Mat matToProcess, std::function<void(std::vector<cv::Point>)>callback );
            
        }
        
    }
}


#endif /* defined(__RRPeeAnalizer__RRCVAdditions__) */
