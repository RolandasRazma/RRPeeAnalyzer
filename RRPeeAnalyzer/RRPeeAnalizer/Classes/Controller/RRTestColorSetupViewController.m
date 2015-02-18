//
//  RRTestColorSetupViewController.m
//  RRPeeAnalizer
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

#import "RRTestColorSetupViewController.h"


@interface RRTestColorSetupViewController () <UITableViewDataSource, UITableViewDelegate>

@end


@implementation RRTestColorSetupViewController {
    __weak IBOutlet UIButton    *_testTypeButton;
    __weak IBOutlet UITextField *_testValueTextField;
    __weak IBOutlet UITextField *_testPlotValueTextField;
    
    NSArray     *_testTypes;
    
    UIColor     *_color;
    NSString    *_testType;
}


#pragma mark -
#pragma mark NSCoder


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ( (self = [super initWithCoder:aDecoder]) ){
        _testTypes = @[
                       @"Leukocytes",
                       @"Nitrite",
                       @"Urobilinogen",
                       @"Protein",
                       @"pH",
                       @"Blood",
                       @"Specific gravity",
                       @"Ketones",
                       @"Bilirubin",
                       @"Glucose"];
    }
    return self;
}


#pragma mark -
#pragma mark UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ( !self.testType ){
        [self setTestType: _testTypes[0]];
    }
}


#pragma mark -
#pragma mark RRTestColorSetupViewController


- (void)setColor:(UIColor *)color {
    _color = [color copy];
    
    [self.view setBackgroundColor: _color];
}


- (void)setTestType:(NSString *)testType {
    _testType = (([_testTypes containsObject:testType])?[testType copy]:_testTypes[0]);
    
    if( self.view ){
        [_testTypeButton setTitle:_testType forState:UIControlStateNormal];
    }
}


- (void)setTestValue:(NSString *)testValue {
    if( self.view ){
        [_testValueTextField setText: testValue];
    }
}


- (NSString *)testValue {
    return _testValueTextField.text;
}


- (void)setTestPlotValue:(float)testPlotValue {
    if( self.view ){
        [_testPlotValueTextField setText: [NSString stringWithFormat:@"%.3f", testPlotValue]];
    }
}


- (float)testPlotValue {
    return [_testPlotValueTextField.text floatValue];
}


- (IBAction)selectTestType {
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    [tableViewController.tableView setDataSource:self];
    [tableViewController.tableView setDelegate:self];
 
    [self.navigationController pushViewController:tableViewController animated:YES];
}


#pragma mark -
#pragma mark UIPickerViewDataSource


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 10;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _testTypes[row];
}


#pragma mark -
#pragma mark UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _testTypes.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if( !tableViewCell ){
        tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    [tableViewCell.textLabel setText: _testTypes[indexPath.row]];
    
    return tableViewCell;
}


#pragma mark -
#pragma mark UITableViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setTestType: _testTypes[indexPath.row]];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
