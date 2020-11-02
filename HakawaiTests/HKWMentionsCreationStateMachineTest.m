//
//  HKWMentionsCreationStateMachine.m
//  Hakawai
//
//  Copyright (c) 2018 LinkedIn Corp. All rights reserved.
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
#import "HKWMentionsPluginV1.h"
#import "HKWMentionsPluginV2.h"
#import "HKWMentionsAttribute.h"
#import "HKWRoundedRectBackgroundAttributeValue.h"
#import "_HKWMentionsCreationStateMachine.h"
#import "_HKWMentionsCreationStateMachineV1.h"
#import "_HKWMentionsCreationStateMachineV2.h"
#import "HKWMentionDataProvider.h"
#import "HKWTDummyMentionsManager.h"

@interface HKWMentionsCreationStateMachineV1 ()

@property (nonatomic) NSArray *entityArray;

@end

@interface HKWMentionsCreationStateMachineV2 ()

@property (nonatomic) HKWMentionDataProvider *dataProvider;

@property (nonatomic, strong) NSMutableString *stringBuffer;

@end

@interface HKWMentionDataProvider ()

@property (nonatomic) NSArray *entityArray;

@end

@interface HKWMentionsPluginV1 () <HKWMentionsDefaultChooserViewDelegate>

@property (nonatomic, strong) id<HKWMentionsCreationStateMachine> creationStateMachine;

@end

@interface HKWMentionsPluginV2 () <HKWMentionsDefaultChooserViewDelegate>

@property (nonatomic, strong) id<HKWMentionsCreationStateMachine> creationStateMachine;

@end

SpecBegin(explicitMentionList)

describe(@"Showing mentions list for explicit search only - MENTIONS PLUGIN V1", ^{
    __block HKWTextView *textView;
    __block HKWMentionsPluginV1 *mentionsPlugin;
    __block HKWTDummyMentionsManager *mentionsManager;

    beforeEach(^{
        textView = [[HKWTextView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        mentionsPlugin = [HKWMentionsPluginV1 mentionsPluginWithChooserMode:HKWMentionsChooserPositionModeCustomLockTopArrowPointingUp
                                                        controlCharacters:[NSCharacterSet characterSetWithCharactersInString:@"@"]
                                                             searchLength:0];
        mentionsManager = [[HKWTDummyMentionsManager alloc] init];
        mentionsPlugin.defaultChooserViewDelegate = mentionsManager;
        [textView setControlFlowPlugin:mentionsPlugin];
    });

    it(@"should not show mention list for email", ^{
        [mentionsPlugin textView:textView shouldChangeTextInRange:NSMakeRange(0, 0) replacementText:@"A"];
        [textView setText:@"A"];
    NSArray *entityArray;
    if (HKWTextView.enableMentionsCreationStateMachineV2) {
        HKWMentionsCreationStateMachineV2 *sm2 = (HKWMentionsCreationStateMachineV2 *)mentionsPlugin.creationStateMachine;
        entityArray = sm2.dataProvider.entityArray;
    } else {
        HKWMentionsCreationStateMachineV1 *sm1 = (HKWMentionsCreationStateMachineV1 *)mentionsPlugin.creationStateMachine;
        entityArray = sm1.entityArray;
    }
    expect(entityArray.count).to.equal(0);

    [mentionsPlugin textView:textView shouldChangeTextInRange:NSMakeRange(1, 0) replacementText:@"B"];
    [textView setText:@"AB"];
    if (HKWTextView.enableMentionsCreationStateMachineV2) {
        HKWMentionsCreationStateMachineV2 *sm2 = (HKWMentionsCreationStateMachineV2 *)mentionsPlugin.creationStateMachine;
        entityArray = sm2.dataProvider.entityArray;
    } else {
        HKWMentionsCreationStateMachineV1 *sm1 = (HKWMentionsCreationStateMachineV1 *)mentionsPlugin.creationStateMachine;
        entityArray = sm1.entityArray;
    }
    expect(entityArray.count).to.equal(0);

    [mentionsPlugin textView:textView shouldChangeTextInRange:NSMakeRange(2, 0) replacementText:@"@"];
    [textView setText:@"AB@"];
    if (HKWTextView.enableMentionsCreationStateMachineV2) {
        HKWMentionsCreationStateMachineV2 *sm2 = (HKWMentionsCreationStateMachineV2 *)mentionsPlugin.creationStateMachine;
        entityArray = sm2.dataProvider.entityArray;
    } else {
        HKWMentionsCreationStateMachineV1 *sm1 = (HKWMentionsCreationStateMachineV1 *)mentionsPlugin.creationStateMachine;
        entityArray = sm1.entityArray;
    }
    expect(entityArray.count).to.equal(0);

    [mentionsPlugin textView:textView shouldChangeTextInRange:NSMakeRange(3, 0) replacementText:@"C"];
    [textView setText:@"AB@C"];
    if (HKWTextView.enableMentionsCreationStateMachineV2) {
        HKWMentionsCreationStateMachineV2 *sm2 = (HKWMentionsCreationStateMachineV2 *)mentionsPlugin.creationStateMachine;
        entityArray = sm2.dataProvider.entityArray;
    } else {
        HKWMentionsCreationStateMachineV1 *sm1 = (HKWMentionsCreationStateMachineV1 *)mentionsPlugin.creationStateMachine;
        entityArray = sm1.entityArray;
    }
    expect(entityArray.count).to.equal(0);
    });

    it(@"should show mention list for non email", ^{
        [mentionsPlugin textView:textView shouldChangeTextInRange:NSMakeRange(0, 0) replacementText:@"A"];
        [textView setText:@"A"];
    NSArray *entityArray;
    if (HKWTextView.enableMentionsCreationStateMachineV2) {
        HKWMentionsCreationStateMachineV2 *sm2 = (HKWMentionsCreationStateMachineV2 *)mentionsPlugin.creationStateMachine;
        entityArray = sm2.dataProvider.entityArray;
    } else {
        HKWMentionsCreationStateMachineV1 *sm1 = (HKWMentionsCreationStateMachineV1 *)mentionsPlugin.creationStateMachine;
        entityArray = sm1.entityArray;
    }
    expect(entityArray.count).to.equal(0);

    [mentionsPlugin textView:textView shouldChangeTextInRange:NSMakeRange(1, 0) replacementText:@" "];
    [textView setText:@"A "];
    if (HKWTextView.enableMentionsCreationStateMachineV2) {
        HKWMentionsCreationStateMachineV2 *sm2 = (HKWMentionsCreationStateMachineV2 *)mentionsPlugin.creationStateMachine;
        entityArray = sm2.dataProvider.entityArray;
    } else {
        HKWMentionsCreationStateMachineV1 *sm1 = (HKWMentionsCreationStateMachineV1 *)mentionsPlugin.creationStateMachine;
        entityArray = sm1.entityArray;
    }
    expect(entityArray.count).to.equal(0);

    [mentionsPlugin textView:textView shouldChangeTextInRange:NSMakeRange(2, 0) replacementText:@"@"];
    [textView setText:@"A @"];
    if (HKWTextView.enableMentionsCreationStateMachineV2) {
        HKWMentionsCreationStateMachineV2 *sm2 = (HKWMentionsCreationStateMachineV2 *)mentionsPlugin.creationStateMachine;
        entityArray = sm2.dataProvider.entityArray;
    } else {
        HKWMentionsCreationStateMachineV1 *sm1 = (HKWMentionsCreationStateMachineV1 *)mentionsPlugin.creationStateMachine;
        entityArray = sm1.entityArray;
    }
    expect(entityArray.count).to.equal(5);
    });

    it(@"should show mentions list for explicit search(when typed control character `@`)", ^{
    NSArray *entityArray;
        [mentionsPlugin textView:textView shouldChangeTextInRange:NSMakeRange(0, 0) replacementText:@"@"];
        [textView setText:@"@"];
    if (HKWTextView.enableMentionsCreationStateMachineV2) {
        HKWMentionsCreationStateMachineV2 *sm2 = (HKWMentionsCreationStateMachineV2 *)mentionsPlugin.creationStateMachine;
        entityArray = sm2.dataProvider.entityArray;
    } else {
        HKWMentionsCreationStateMachineV1 *sm1 = (HKWMentionsCreationStateMachineV1 *)mentionsPlugin.creationStateMachine;
        entityArray = sm1.entityArray;
    }
    expect(entityArray.count).to.equal(5);
    });

    it(@"should trigger initial fetch mentions request when text begins editing", ^{
    NSArray *entityArray;
        [textView.delegate textViewShouldBeginEditing:textView];
    if (HKWTextView.enableMentionsCreationStateMachineV2) {
        HKWMentionsCreationStateMachineV2 *sm2 = (HKWMentionsCreationStateMachineV2 *)mentionsPlugin.creationStateMachine;
        entityArray = sm2.dataProvider.entityArray;
    } else {
        HKWMentionsCreationStateMachineV1 *sm1 = (HKWMentionsCreationStateMachineV1 *)mentionsPlugin.creationStateMachine;
        entityArray = sm1.entityArray;
    }
    expect(entityArray.count).to.equal(1);
    });
});

describe(@"Showing mentions list for explicit search only - MENTIONS PLUGIN V2", ^{
    __block HKWTextView *textView;
    __block HKWMentionsPluginV2 *mentionsPlugin;
    __block HKWTDummyMentionsManager *mentionsManager;

    beforeEach(^{
        HKWTextView.enableMentionsPluginV2 = YES;
        textView = [[HKWTextView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        mentionsPlugin = [HKWMentionsPluginV2 mentionsPluginWithChooserMode:HKWMentionsChooserPositionModeCustomLockTopArrowPointingUp
                                                        controlCharacters:[NSCharacterSet characterSetWithCharactersInString:@"@"]
                                                             searchLength:0];
        mentionsManager = [[HKWTDummyMentionsManager alloc] init];
        mentionsPlugin.defaultChooserViewDelegate = mentionsManager;
        [textView setControlFlowPlugin:mentionsPlugin];
    });

    afterAll(^{
        HKWTextView.enableMentionsPluginV2 = NO;
    });

    it(@"should not show mention list for email", ^{
        [mentionsPlugin textView:textView shouldChangeTextInRange:NSMakeRange(0, 0) replacementText:@"A"];
        [textView setText:@"A"];
    NSArray *entityArray;
    if (HKWTextView.enableMentionsCreationStateMachineV2) {
        HKWMentionsCreationStateMachineV2 *sm2 = (HKWMentionsCreationStateMachineV2 *)mentionsPlugin.creationStateMachine;
        entityArray = sm2.dataProvider.entityArray;
    } else {
        HKWMentionsCreationStateMachineV1 *sm1 = (HKWMentionsCreationStateMachineV1 *)mentionsPlugin.creationStateMachine;
        entityArray = sm1.entityArray;
    }
    expect(entityArray.count).to.equal(0);

    [mentionsPlugin textView:textView shouldChangeTextInRange:NSMakeRange(1, 0) replacementText:@"B"];
    [textView setText:@"AB"];
    if (HKWTextView.enableMentionsCreationStateMachineV2) {
        HKWMentionsCreationStateMachineV2 *sm2 = (HKWMentionsCreationStateMachineV2 *)mentionsPlugin.creationStateMachine;
        entityArray = sm2.dataProvider.entityArray;
    } else {
        HKWMentionsCreationStateMachineV1 *sm1 = (HKWMentionsCreationStateMachineV1 *)mentionsPlugin.creationStateMachine;
        entityArray = sm1.entityArray;
    }
    expect(entityArray.count).to.equal(0);

    [mentionsPlugin textView:textView shouldChangeTextInRange:NSMakeRange(2, 0) replacementText:@"@"];
    [textView setText:@"AB@"];
    if (HKWTextView.enableMentionsCreationStateMachineV2) {
        HKWMentionsCreationStateMachineV2 *sm2 = (HKWMentionsCreationStateMachineV2 *)mentionsPlugin.creationStateMachine;
        entityArray = sm2.dataProvider.entityArray;
    } else {
        HKWMentionsCreationStateMachineV1 *sm1 = (HKWMentionsCreationStateMachineV1 *)mentionsPlugin.creationStateMachine;
        entityArray = sm1.entityArray;
    }
    expect(entityArray.count).to.equal(0);

    [mentionsPlugin textView:textView shouldChangeTextInRange:NSMakeRange(3, 0) replacementText:@"C"];
    [textView setText:@"AB@C"];
    if (HKWTextView.enableMentionsCreationStateMachineV2) {
        HKWMentionsCreationStateMachineV2 *sm2 = (HKWMentionsCreationStateMachineV2 *)mentionsPlugin.creationStateMachine;
        entityArray = sm2.dataProvider.entityArray;
    } else {
        HKWMentionsCreationStateMachineV1 *sm1 = (HKWMentionsCreationStateMachineV1 *)mentionsPlugin.creationStateMachine;
        entityArray = sm1.entityArray;
    }
    expect(entityArray.count).to.equal(0);
    });

    it(@"should show mention list for non email", ^{
        [mentionsPlugin textView:textView shouldChangeTextInRange:NSMakeRange(0, 0) replacementText:@"A"];
        [textView setText:@"A"];
    NSArray *entityArray;
    if (HKWTextView.enableMentionsCreationStateMachineV2) {
        HKWMentionsCreationStateMachineV2 *sm2 = (HKWMentionsCreationStateMachineV2 *)mentionsPlugin.creationStateMachine;
        entityArray = sm2.dataProvider.entityArray;
    } else {
        HKWMentionsCreationStateMachineV1 *sm1 = (HKWMentionsCreationStateMachineV1 *)mentionsPlugin.creationStateMachine;
        entityArray = sm1.entityArray;
    }
    expect(entityArray.count).to.equal(0);

    [mentionsPlugin textView:textView shouldChangeTextInRange:NSMakeRange(1, 0) replacementText:@" "];
    [textView setText:@"A "];
    if (HKWTextView.enableMentionsCreationStateMachineV2) {
        HKWMentionsCreationStateMachineV2 *sm2 = (HKWMentionsCreationStateMachineV2 *)mentionsPlugin.creationStateMachine;
        entityArray = sm2.dataProvider.entityArray;
    } else {
        HKWMentionsCreationStateMachineV1 *sm1 = (HKWMentionsCreationStateMachineV1 *)mentionsPlugin.creationStateMachine;
        entityArray = sm1.entityArray;
    }
    expect(entityArray.count).to.equal(0);

    [mentionsPlugin textView:textView shouldChangeTextInRange:NSMakeRange(2, 0) replacementText:@"@"];
    [textView setText:@"A @"];
    if (HKWTextView.enableMentionsCreationStateMachineV2) {
        HKWMentionsCreationStateMachineV2 *sm2 = (HKWMentionsCreationStateMachineV2 *)mentionsPlugin.creationStateMachine;
        entityArray = sm2.dataProvider.entityArray;
    } else {
        HKWMentionsCreationStateMachineV1 *sm1 = (HKWMentionsCreationStateMachineV1 *)mentionsPlugin.creationStateMachine;
        entityArray = sm1.entityArray;
    }
    expect(entityArray.count).to.equal(5);
    });

    it(@"should show mentions list for explicit search(when typed control character `@`)", ^{
    NSArray *entityArray;
        [mentionsPlugin textView:textView shouldChangeTextInRange:NSMakeRange(0, 0) replacementText:@"@"];
        [textView setText:@"@"];
    if (HKWTextView.enableMentionsCreationStateMachineV2) {
        HKWMentionsCreationStateMachineV2 *sm2 = (HKWMentionsCreationStateMachineV2 *)mentionsPlugin.creationStateMachine;
        entityArray = sm2.dataProvider.entityArray;
    } else {
        HKWMentionsCreationStateMachineV1 *sm1 = (HKWMentionsCreationStateMachineV1 *)mentionsPlugin.creationStateMachine;
        entityArray = sm1.entityArray;
    }
    expect(entityArray.count).to.equal(5);
    });

    it(@"should trigger initial fetch mentions request when text begins editing", ^{
        NSArray *entityArray;
            [textView.delegate textViewShouldBeginEditing:textView];
        if (HKWTextView.enableMentionsCreationStateMachineV2) {
            HKWMentionsCreationStateMachineV2 *sm2 = (HKWMentionsCreationStateMachineV2 *)mentionsPlugin.creationStateMachine;
            entityArray = sm2.dataProvider.entityArray;
        } else {
            HKWMentionsCreationStateMachineV1 *sm1 = (HKWMentionsCreationStateMachineV1 *)mentionsPlugin.creationStateMachine;
            entityArray = sm1.entityArray;
        }
        expect(entityArray.count).to.equal(1);
    });
});

describe(@"Test basic mention typing logic in multiple languages - MENTIONS PLUGIN V2", ^{
    __block HKWTextView *textView;
    __block HKWMentionsPluginV2 *mentionsPlugin;
    __block HKWTDummyMentionsManager *mentionsManager;

     beforeEach(^{
         HKWTextView.enableMentionsCreationStateMachineV2 = YES;
         HKWTextView.enableMentionsPluginV2 = YES;
         textView = [[HKWTextView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
         mentionsPlugin = [HKWMentionsPluginV2 mentionsPluginWithChooserMode:HKWMentionsChooserPositionModeCustomLockTopArrowPointingUp
                                                         controlCharacters:[NSCharacterSet characterSetWithCharactersInString:@"@"]
                                                              searchLength:0];
         mentionsManager = [[HKWTDummyMentionsManager alloc] init];
         mentionsPlugin.defaultChooserViewDelegate = mentionsManager;
         [textView setControlFlowPlugin:mentionsPlugin];
     });

     afterAll(^{
         HKWTextView.enableMentionsPluginV2 = NO;
         HKWTextView.enableMentionsCreationStateMachineV2 = NO;
     });

    it(@"test with english", ^{
        [textView insertText:@"@"];
        [textView insertText:@"a"];
        // Text: @a
        HKWMentionsCreationStateMachineV2 *creationStateMachine = (HKWMentionsCreationStateMachineV2 *)mentionsPlugin.creationStateMachine;
        expect(creationStateMachine.stringBuffer).to.equal(@"a");
        [textView insertText:@"b"];
        // Text: @ab
        expect(creationStateMachine.stringBuffer).to.equal(@"ab");
        [textView deleteBackward];
        // Text: @a
        expect(creationStateMachine.stringBuffer).to.equal(@"a");
        [textView deleteBackward];
        // Text: @
        expect(creationStateMachine.stringBuffer).to.equal(@"");
        [textView insertText:@"ab"];
        // Text: @ab
        expect(creationStateMachine.stringBuffer).to.equal(@"ab");
    });

    it(@"test with korean hanji", ^{
        [textView insertText:@"@"];
        [textView insertText:@"ㄱ"];
        // Text: @ㄱ
        HKWMentionsCreationStateMachineV2 *creationStateMachine = (HKWMentionsCreationStateMachineV2 *)mentionsPlugin.creationStateMachine;
        expect(creationStateMachine.stringBuffer).to.equal(@"ㄱ");
        [textView insertText:@"ㅣ"];
        // Text: @ㄱㅣ
        expect(creationStateMachine.stringBuffer).to.equal(@"ㄱㅣ");
        [textView deleteBackward];
        // Text: @ㄱ
        expect(creationStateMachine.stringBuffer).to.equal(@"ㄱ");
        [textView deleteBackward];
        // Text: @
        expect(creationStateMachine.stringBuffer).to.equal(@"");
        [textView insertText:@"ㄱㅣ"];
        // Text: @ㄱㅣ
        expect(creationStateMachine.stringBuffer).to.equal(@"ㄱㅣ");
    });

    it(@"test with emojis", ^{
        [textView insertText:@"@"];
        [textView insertText:@"😁"];
        // Text: @😁
        HKWMentionsCreationStateMachineV2 *creationStateMachine = (HKWMentionsCreationStateMachineV2 *)mentionsPlugin.creationStateMachine;
        expect(creationStateMachine.stringBuffer).to.equal(@"😁");
        [textView insertText:@"😁"];
        // Text: @😁😁
        expect(creationStateMachine.stringBuffer).to.equal(@"😁😁");
        [textView deleteBackward];
        // Text: @😁
        expect(creationStateMachine.stringBuffer).to.equal(@"😁");
        [textView deleteBackward];
        // Text: @
        expect(creationStateMachine.stringBuffer).to.equal(@"");
        [textView insertText:@"asdf 😁"];
        // Text: @asdf 😁
        expect(creationStateMachine.stringBuffer).to.equal(@"asdf 😁");
    });
});

SpecEnd
