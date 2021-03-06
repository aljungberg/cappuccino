/*
 * CPCheckBox.j
 * AppKit
 *
 * Created by Francisco Tolmasky.
 * Copyright 2009, 280 North, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

@import "CPButton.j"


CPCheckBoxImageOffset = 4.0;

@implementation CPCheckBox : CPButton
{
}

+ (id)checkBoxWithTitle:(CPString)aTitle theme:(CPTheme)aTheme
{
    return [self buttonWithTitle:aTitle theme:aTheme];
}

+ (id)checkBoxWithTitle:(CPString)aTitle
{
    return [self buttonWithTitle:aTitle];
}

+ (CPString)defaultThemeClass
{
    return @"check-box";
}

+ (Class)_binderClassForBinding:(CPString)theBinding
{
    if (theBinding === CPValueBinding)
        return [_CPCheckBoxValueBinder class];

    return [super _binderClassForBinding:theBinding];
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        [self setHighlightsBy:CPContentsCellMask];
        [self setShowsStateBy:CPContentsCellMask];

        // Defaults?
        [self setImagePosition:CPImageLeft];
        [self setAlignment:CPLeftTextAlignment];

        [self setBordered:NO];
    }

    return self;
}

- (void)takeStateFromKeyPath:(CPString)aKeyPath ofObjects:(CPArray)objects
{
    var count = objects.length,
        value = [objects[0] valueForKeyPath:aKeyPath] ? CPOnState : CPOffState;

    [self setAllowsMixedState:NO];
    [self setState:value];

    while (count-- > 1)
    {
        if (value !== ([objects[count] valueForKeyPath:aKeyPath] ? CPOnState : CPOffState))
        {
            [self setAllowsMixedState:YES];
            [self setState:CPMixedState];
        }
    }
}

- (void)takeValueFromKeyPath:(CPString)aKeyPath ofObjects:(CPArray)objects
{
    [self takeStateFromKeyPath:aKeyPath ofObjects:objects];
}

@end

@implementation _CPCheckBoxValueBinder : CPBinder
{
}

- (void)_updatePlaceholdersWithOptions:(CPDictionary)options
{
    [super _updatePlaceholdersWithOptions:options];

    [self _setPlaceholder:CPMixedState forMarker:CPMultipleValuesMarker isDefault:YES];
    [self _setPlaceholder:CPOffState forMarker:CPNoSelectionMarker isDefault:YES];
    [self _setPlaceholder:CPOffState forMarker:CPNotApplicableMarker isDefault:YES];
    [self _setPlaceholder:CPOffState forMarker:CPNullMarker isDefault:YES];
}

- (void)setValueFor:(CPString)theBinding
{
    var destination = [_info objectForKey:CPObservedObjectKey],
        keyPath = [_info objectForKey:CPObservedKeyPathKey],
        options = [_info objectForKey:CPOptionsKey],
        newValue = [destination valueForKeyPath:keyPath],
        isPlaceholder = CPIsControllerMarker(newValue);

    if (isPlaceholder)
    {
        if (newValue === CPNotApplicableMarker && [options objectForKey:CPRaisesForNotApplicableKeysBindingOption])
        {
           [CPException raise:CPGenericException
                       reason:@"can't transform non applicable key on: " + _source + " value: " + newValue];
        }

        newValue = [self _placeholderForMarker:newValue];

        if (newValue === CPMixedState)
        {
            [_source setAllowsMixedState:YES];
        }
        else
        {
            // Cocoa will always set allowsMixedState to NO
            // This behavior will be fine for Cappuccino as well if we (like Cocoa)
            // default the CPConditionallySetsEnabledBindingOption to YES
            [_source setAllowsMixedState:NO];
        }
    }

    [_source setState:newValue];
}

@end
