//
//  HKWMentionsPluginTests.m
//  Hakawai
//
//  Created by Matthew Schouest on 8/17/17.
//  Copyright (c) 2017 LinkedIn Corp. All rights reserved.
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
//  the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//

#define EXP_SHORTHAND

#import "Specta.h"
#import "Expecta.h"

#import "HKWTextView.h"
#import "HKWMentionsPlugin.h"
#import "HKWMentionsPluginV1.h"
#import "HKWMentionsPluginV2.h"
#import "HKWMentionsAttribute.h"

@interface HKWMentionsPluginV1 ()
- (BOOL)stringValidForMentionsCreation:(NSString *)string;
@end

@interface HKWMentionsPluginV2 ()
- (BOOL)stringValidForMentionsCreation:(NSString *)string;
@end

@interface HKWDummyMentionsDefaultChooserViewDelegate : NSObject <HKWMentionsDefaultChooserViewDelegate>

@property (nonatomic) NSArray<NSString *> *trimmableStrings;

- (instancetype)initWithTrimmableStrings:(NSArray<NSString *> *)trimmableStrings;

- (BOOL)entityCanBeTrimmed:(id<HKWMentionsEntityProtocol> _Null_unspecified)entity;

- (nonnull NSString *)trimmedNameForEntity:(id<HKWMentionsEntityProtocol> _Null_unspecified)entity;

@end

@implementation HKWDummyMentionsDefaultChooserViewDelegate

- (instancetype)initWithTrimmableStrings:(NSArray<NSString *> *)trimmableStrings;
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.trimmableStrings = trimmableStrings;
    return self;
}

- (BOOL)entityCanBeTrimmed:(id<HKWMentionsEntityProtocol> _Null_unspecified)entity {
    return [self.trimmableStrings containsObject:entity.entityName];
}

- (nonnull NSString *)trimmedNameForEntity:(id<HKWMentionsEntityProtocol> _Null_unspecified)entity {
    return [entity.entityName componentsSeparatedByString:@" "][0];
}

- (void)asyncRetrieveEntitiesForKeyString:(nonnull NSString *)keyString searchType:(HKWMentionsSearchType)type controlCharacter:(unichar)character completion:(void (^ _Null_unspecified)(NSArray * _Null_unspecified, BOOL, BOOL))completionBlock {
}


- (UITableViewCell * _Null_unspecified)cellForMentionsEntity:(id<HKWMentionsEntityProtocol> _Null_unspecified)entity withMatchString:(NSString * _Null_unspecified)matchString tableView:(UITableView * _Null_unspecified)tableView atIndexPath:(NSIndexPath * _Null_unspecified)indexPath {
    return nil;
}


- (CGFloat)heightForCellForMentionsEntity:(id<HKWMentionsEntityProtocol> _Null_unspecified)entity tableView:(UITableView * _Null_unspecified)tableView {
    return 0.0;
}


@end

SpecBegin(mentionPluginsSetup)

describe(@"basic mentions plugin setup - MENTIONS PLUGIN V1", ^{
    __block HKWTextView *textView;

    beforeEach(^{
        textView = [[HKWTextView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    });

    it(@"should properly register and unregister mentions plug-in", ^{
        HKWMentionsPluginV1 *plugin = [HKWMentionsPluginV1 mentionsPluginWithChooserMode:HKWMentionsChooserPositionModeCustomLockTopArrowPointingUp];
        // Add plug-ins
        [textView setControlFlowPlugin:plugin];
        expect([textView controlFlowPlugin]).to.beKindOf(HKWMentionsPluginV1.class);

        // Check parentTextView
        expect(plugin.parentTextView).to.equal(textView);

        // Remove plug-in
        textView.controlFlowPlugin = nil;
        expect(textView.controlFlowPlugin).to.beNil;
        expect(plugin.parentTextView).to.beNil;
    });
});

describe(@"basic mentions plugin setup - MENTIONS PLUGIN V2", ^{
    __block HKWTextView *textView;

    beforeEach(^{
        textView = [[HKWTextView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    });

    it(@"should properly register and unregister mentions plug-in", ^{
        HKWMentionsPluginV2 *plugin = [HKWMentionsPluginV2 mentionsPluginWithChooserMode:HKWMentionsChooserPositionModeCustomLockTopArrowPointingUp];
        // Add plug-ins
        [textView setControlFlowPlugin:plugin];
        expect([textView controlFlowPlugin]).to.beKindOf(HKWMentionsPluginV2.class);

        // Check parentTextView
        expect(plugin.parentTextView).to.equal(textView);

        // Remove plug-in
        textView.controlFlowPlugin = nil;
        expect(textView.controlFlowPlugin).to.beNil;
        expect(plugin.parentTextView).to.beNil;
    });
});

describe(@"inserting and reading mentions - MENTIONS PLUGIN V1", ^{
    __block HKWTextView *textView;
    __block HKWMentionsPluginV1 *mentionsPlugin;

    beforeEach(^{
        textView = [[HKWTextView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        mentionsPlugin = [HKWMentionsPluginV1 mentionsPluginWithChooserMode:HKWMentionsChooserPositionModeCustomLockTopArrowPointingUp];
        [textView setControlFlowPlugin:mentionsPlugin];
    });

    it(@"should properly return mentions", ^{
        HKWMentionsAttribute *m1 = [HKWMentionsAttribute mentionWithText:@"Asdf ghjkl" identifier:@"1"];
        HKWMentionsAttribute *m2 = [HKWMentionsAttribute mentionWithText:@"Qwerty Uiop" identifier:@"2"];

        expect(mentionsPlugin.mentions.count).to.equal(0);

        [textView insertText:m1.mentionText];
        m1.range = NSMakeRange(0, m1.mentionText.length);

        [mentionsPlugin addMention:m1];
        expect(mentionsPlugin.mentions.count).to.equal(1);
        

        [textView insertText:@" "];

        [textView insertText:m2.mentionText];
        m2.range = NSMakeRange(m1.mentionText.length + 1, m2.mentionText.length);
        [mentionsPlugin addMention:m2];

        expect(mentionsPlugin.mentions.count).to.equal(2);
    });

    it(@"should properly handle mentions containing emoji", ^{
        HKWMentionsAttribute *m1 = [HKWMentionsAttribute mentionWithText:@"Asdf ghjk🐝" identifier:@"1"];
        HKWMentionsAttribute *m2 = [HKWMentionsAttribute mentionWithText:@"Qwerty👨‍👩‍👧‍👧 Uiop" identifier:@"2"];

        expect(mentionsPlugin.mentions.count).to.equal(0);

        [textView insertText:m1.mentionText];
        m1.range = NSMakeRange(0, m1.mentionText.length);

        [mentionsPlugin addMention:m1];
        expect(mentionsPlugin.mentions.count).to.equal(1);
        

        [textView insertText:@" "];

        [textView insertText:m2.mentionText];
        m2.range = NSMakeRange(m1.mentionText.length + 1, m2.mentionText.length);
        [mentionsPlugin addMention:m2];
        expect(mentionsPlugin.mentions.count).to.equal(2);
    });

    it(@"should properly handle mentions containing only emoji", ^{
        HKWMentionsAttribute *m1 = [HKWMentionsAttribute mentionWithText:@"🐝🙅‍♂️ 👨‍👨‍👧👔" identifier:@"1"];
        HKWMentionsAttribute *m2 = [HKWMentionsAttribute mentionWithText:@"🦎🌘" identifier:@"2"];

        expect(mentionsPlugin.mentions.count).to.equal(0);

        [textView insertText:m1.mentionText];
        m1.range = NSMakeRange(0, m1.mentionText.length);

        [mentionsPlugin addMention:m1];
        expect(mentionsPlugin.mentions.count).to.equal(1);

        [textView insertText:@" "];

        [textView insertText:m2.mentionText];
        m2.range = NSMakeRange(m1.mentionText.length + 1, m2.mentionText.length);
        [mentionsPlugin addMention:m2];

        expect(mentionsPlugin.mentions.count).to.equal(2);
    });
});

describe(@"inserting and reading mentions - MENTIONS PLUGIN V2", ^{
    __block HKWTextView *textView;
    __block HKWMentionsPluginV2 *mentionsPlugin;

    beforeEach(^{
        textView = [[HKWTextView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        mentionsPlugin = [HKWMentionsPluginV1 mentionsPluginWithChooserMode:HKWMentionsChooserPositionModeCustomLockTopArrowPointingUp];
        [textView setControlFlowPlugin:mentionsPlugin];
    });

    it(@"should properly return mentions", ^{
        HKWMentionsAttribute *m1 = [HKWMentionsAttribute mentionWithText:@"Asdf ghjkl" identifier:@"1"];
        HKWMentionsAttribute *m2 = [HKWMentionsAttribute mentionWithText:@"Qwerty Uiop" identifier:@"2"];

        expect(mentionsPlugin.mentions.count).to.equal(0);

        [textView insertText:m1.mentionText];
        m1.range = NSMakeRange(0, m1.mentionText.length);

        [mentionsPlugin addMention:m1];
        expect(mentionsPlugin.mentions.count).to.equal(1);

        [textView insertText:@" "];

        [textView insertText:m2.mentionText];
        m2.range = NSMakeRange(m1.mentionText.length + 1, m2.mentionText.length);
        [mentionsPlugin addMention:m2];

        expect(mentionsPlugin.mentions.count).to.equal(2);
    });

    it(@"should properly handle mentions containing emoji", ^{
        HKWMentionsAttribute *m1 = [HKWMentionsAttribute mentionWithText:@"Asdf ghjk🐝" identifier:@"1"];
        HKWMentionsAttribute *m2 = [HKWMentionsAttribute mentionWithText:@"Qwerty👨‍👩‍👧‍👧 Uiop" identifier:@"2"];

        expect(mentionsPlugin.mentions.count).to.equal(0);

        [textView insertText:m1.mentionText];
        m1.range = NSMakeRange(0, m1.mentionText.length);

        [mentionsPlugin addMention:m1];
        expect(mentionsPlugin.mentions.count).to.equal(1);


        [textView insertText:@" "];

        [textView insertText:m2.mentionText];
        m2.range = NSMakeRange(m1.mentionText.length + 1, m2.mentionText.length);
        [mentionsPlugin addMention:m2];
        expect(mentionsPlugin.mentions.count).to.equal(2);
    });

    it(@"should properly handle mentions containing only emoji", ^{
        HKWMentionsAttribute *m1 = [HKWMentionsAttribute mentionWithText:@"🐝🙅‍♂️ 👨‍👨‍👧👔" identifier:@"1"];
        HKWMentionsAttribute *m2 = [HKWMentionsAttribute mentionWithText:@"🦎🌘" identifier:@"2"];

        expect(mentionsPlugin.mentions.count).to.equal(0);

        [textView insertText:m1.mentionText];
        m1.range = NSMakeRange(0, m1.mentionText.length);

        [mentionsPlugin addMention:m1];
        expect(mentionsPlugin.mentions.count).to.equal(1);

        [textView insertText:@" "];

        [textView insertText:m2.mentionText];
        m2.range = NSMakeRange(m1.mentionText.length + 1, m2.mentionText.length);
        [mentionsPlugin addMention:m2];

        expect(mentionsPlugin.mentions.count).to.equal(2);
    });
});

describe(@"mentions validation - MENTIONS PLUGIN V1", ^{
    __block HKWTextView *textView;
    __block HKWMentionsPluginV1 *mentionsPlugin;

    beforeEach(^{
        textView = [[HKWTextView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        mentionsPlugin = [HKWMentionsPluginV1 mentionsPluginWithChooserMode:HKWMentionsChooserPositionModeCustomLockTopArrowPointingUp];
        [textView setControlFlowPlugin:mentionsPlugin];
    });

    it(@"check the string validation for dictation string", ^{
        NSString *const mentionString = @"Alan Perkis";

        // Multi word string should not be valid for mentions creation
        BOOL isStringValid = [mentionsPlugin stringValidForMentionsCreation:mentionString];
        expect(isStringValid).to.equal(NO);

        // Multi word string should be valid for mentions creation, only if it matches the dictation string
        [mentionsPlugin setDictationString:mentionString];
        isStringValid = [mentionsPlugin stringValidForMentionsCreation:mentionString];
        expect(isStringValid).to.equal(YES);
    });
});

describe(@"mentions validation - MENTIONS PLUGIN V2", ^{
    __block HKWTextView *textView;
    __block HKWMentionsPluginV2 *mentionsPlugin;

    beforeEach(^{
        textView = [[HKWTextView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        mentionsPlugin = [HKWMentionsPluginV2 mentionsPluginWithChooserMode:HKWMentionsChooserPositionModeCustomLockTopArrowPointingUp];
        [textView setControlFlowPlugin:mentionsPlugin];
    });

    it(@"check the string validation for dictation string", ^{
        NSString *const mentionString = @"Alan Perkis";

        // Multi word string should not be valid for mentions creation
        BOOL isStringValid = [mentionsPlugin stringValidForMentionsCreation:mentionString];
        expect(isStringValid).to.equal(NO);

        // Multi word string should be valid for mentions creation, only if it matches the dictation string
        [mentionsPlugin setDictationString:mentionString];
        isStringValid = [mentionsPlugin stringValidForMentionsCreation:mentionString];
        expect(isStringValid).to.equal(YES);
    });
});

describe(@"deleting and reading mentions - MENTIONS PLUGIN V1", ^{
    __block HKWTextView *textView;
    __block HKWMentionsPluginV1 *mentionsPlugin;

    beforeEach(^{
        textView = [[HKWTextView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        mentionsPlugin = [HKWMentionsPluginV1 mentionsPluginWithChooserMode:HKWMentionsChooserPositionModeCustomLockTopArrowPointingUp];
        [textView setControlFlowPlugin:mentionsPlugin];
    });

    it(@"should properly handle mention deletion", ^{
        HKWMentionsAttribute *m1 = [HKWMentionsAttribute mentionWithText:@"Asdf ghjkl" identifier:@"1"];

        expect(mentionsPlugin.mentions.count).to.equal(0);

        [textView insertText:m1.mentionText];
        m1.range = NSMakeRange(0, m1.mentionText.length);

        [mentionsPlugin addMention:m1];
        expect(mentionsPlugin.mentions.count).to.equal(1);

        // the first attempt to delete mention should select the mention and modify the state. No changes apply to the mention and text
        BOOL deletionResult1 = [mentionsPlugin textView:textView shouldChangeTextInRange:NSMakeRange(m1.mentionText.length-1, 1) replacementText:@""];
        expect(deletionResult1).to.equal(NO);
        expect(mentionsPlugin.mentions.count).to.equal(1);

        // the second attempt deletes the whole mention
        BOOL deletionResult2 = [mentionsPlugin textView:textView shouldChangeTextInRange:NSMakeRange(m1.mentionText.length-1, 1) replacementText:@""];
        expect(deletionResult2).to.equal(NO);
        expect(mentionsPlugin.mentions.count).to.equal(0);
        expect([textView.text length]).to.equal(0);
        

    });
});

describe(@"deleting and reading mentions - MENTIONS PLUGIN V2", ^{
    __block HKWTextView *textView;
    __block HKWMentionsPluginV2 *mentionsPlugin;

    beforeEach(^{
        textView = [[HKWTextView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        mentionsPlugin = [HKWMentionsPluginV2 mentionsPluginWithChooserMode:HKWMentionsChooserPositionModeCustomLockTopArrowPointingUp];
        [textView setControlFlowPlugin:mentionsPlugin];
    });

    it(@"should properly handle mention deletion", ^{
        HKWMentionsAttribute *m1 = [HKWMentionsAttribute mentionWithText:@"Asdf ghjkl" identifier:@"1"];

        expect(mentionsPlugin.mentions.count).to.equal(0);

        [textView insertText:m1.mentionText];
        m1.range = NSMakeRange(0, m1.mentionText.length);

        [mentionsPlugin addMention:m1];
        expect(mentionsPlugin.mentions.count).to.equal(1);

        // delete the whole mention
        BOOL deletionResult2 = [mentionsPlugin textView:textView shouldChangeTextInRange:NSMakeRange(m1.mentionText.length-1, 1) replacementText:@""];
        expect(deletionResult2).to.equal(NO);
        expect(mentionsPlugin.mentions.count).to.equal(0);
        expect([textView.text length]).to.equal(0);
    });

    it(@"should properly handle range mention deletion", ^{
        HKWMentionsAttribute *m1 = [HKWMentionsAttribute mentionWithText:@"Asdf ghjkl" identifier:@"1"];
        HKWMentionsAttribute *m2 = [HKWMentionsAttribute mentionWithText:@"Asdf ghjkll" identifier:@"2"];

        expect(mentionsPlugin.mentions.count).to.equal(0);

        [textView insertText:m1.mentionText];
        NSString *string = @" Hello ";
        [textView insertText:string];
        [textView insertText:m2.mentionText];
        m1.range = NSMakeRange(0, m1.mentionText.length);
        m2.range = NSMakeRange(m1.mentionText.length + string.length, m2.mentionText.length);

        [mentionsPlugin addMention:m1];
        [mentionsPlugin addMention:m2];
        expect(mentionsPlugin.mentions.count).to.equal(2);

        // delete the whole mention
        NSUInteger middleOfMention1 = m1.mentionText.length/2;
        BOOL deletionResult2 = [mentionsPlugin textView:textView shouldChangeTextInRange:NSMakeRange(middleOfMention1, m1.mentionText.length+string.length+m2.mentionText.length/2-middleOfMention1) replacementText:@""];
        expect(deletionResult2).to.equal(NO);
        expect(mentionsPlugin.mentions.count).to.equal(0);
        expect([textView.text length]).to.equal(0);
    });

    it(@"should properly handle range mention deletion with trimming", ^{
        NSString *firstString = @"Asdf ghjkl";
        NSString *secondString = @"Asdf ghjkll";
        HKWDummyMentionsDefaultChooserViewDelegate *delegate = [[HKWDummyMentionsDefaultChooserViewDelegate alloc] initWithTrimmableStrings:@[firstString, secondString]];
        mentionsPlugin.defaultChooserViewDelegate = delegate;
        HKWMentionsAttribute *m1 = [HKWMentionsAttribute mentionWithText:firstString identifier:@"3"];
        HKWMentionsAttribute *m2 = [HKWMentionsAttribute mentionWithText:secondString identifier:@"4"];

        expect(mentionsPlugin.mentions.count).to.equal(0);

        [textView insertText:m1.mentionText];
        NSString *string = @" Hello ";
        [textView insertText:string];
        [textView insertText:m2.mentionText];
        m1.range = NSMakeRange(0, m1.mentionText.length);
        m2.range = NSMakeRange(m1.mentionText.length + string.length, m2.mentionText.length);

        [mentionsPlugin addMention:m1];
        [mentionsPlugin addMention:m2];
        expect(mentionsPlugin.mentions.count).to.equal(2);

        // delete the whole mention
        NSUInteger middleOfMention1 = m1.mentionText.length/2;
        BOOL deletionResult2 = [mentionsPlugin textView:textView shouldChangeTextInRange:NSMakeRange(middleOfMention1, m1.mentionText.length+string.length+m2.mentionText.length/2-middleOfMention1) replacementText:@""];
        expect(deletionResult2).to.equal(NO);
        expect(mentionsPlugin.mentions.count).to.equal(2);
        expect([textView.text length]).to.equal(m1.mentionText.length + m2.mentionText.length);
    });

         
});

SpecEnd
