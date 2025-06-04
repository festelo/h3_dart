//
//  H3Test.m
//  Runner
//
//  Created by Ilya Beregovsky on 29.05.2025.
//

#import <Foundation/Foundation.h>
#import <h3api.h>

void testH3() {
    double degrees = 180.0;
    double radians = degsToRads(degrees);
    NSLog(@"H3 Test: %f degrees = %f radians", degrees, radians);
}
