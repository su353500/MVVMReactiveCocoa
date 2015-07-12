//
//  MRCNewsItemViewModel.m
//  MVVMReactiveCocoa
//
//  Created by leichunfeng on 15/7/5.
//  Copyright (c) 2015年 leichunfeng. All rights reserved.
//

#import "MRCNewsItemViewModel.h"
#import "TTTTimeIntervalFormatter.h"

@interface MRCNewsItemViewModel ()

@property (strong, nonatomic, readwrite) OCTEvent *event;
@property (strong, nonatomic, readwrite) NSAttributedString *attributedString;

@end

@implementation MRCNewsItemViewModel

- (instancetype)initWithEvent:(OCTEvent *)event {
    self = [super init];
    if (self) {
        self.event = event;

        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
        
        NSDictionary *normalTitleAttributes = @{
        	NSFontAttributeName: [UIFont systemFontOfSize:13],
            NSForegroundColorAttributeName: HexRGB(0x666666)
        };
        
        NSDictionary *boldTitleAttributes = @{
            NSFontAttributeName: [UIFont boldSystemFontOfSize:14],
            NSForegroundColorAttributeName: HexRGB(0x333333)
        };
        
        NSDictionary *octiconAttributes = @{
            NSFontAttributeName: [UIFont fontWithName:kOcticonsFamilyName size:16],
            NSForegroundColorAttributeName: HexRGB(0xbbbbbb)
        };
        
        NSDictionary *tintedAttributes = @{
            NSForegroundColorAttributeName: HexRGB(0x4078c0)
        };
        
        NSDictionary *timeAttributes = @{
            NSFontAttributeName: [UIFont systemFontOfSize:12],
            NSForegroundColorAttributeName: HexRGB(0xbbbbbb)
        };
        
        NSDictionary *normalPullInfoAttributes = @{
            NSFontAttributeName: [UIFont systemFontOfSize:12],
            NSForegroundColorAttributeName: RGBAlpha(0, 0, 0, 0.5)
        };
        
        NSDictionary *boldPullInfoAttributes = @{
            NSFontAttributeName: [UIFont boldSystemFontOfSize:12],
            NSForegroundColorAttributeName: RGBAlpha(0, 0, 0, 0.5)
        };
        
        if ([event.type isEqualToString:@"CommitCommentEvent"]) {
            OCTCommitCommentEvent *concreteEvent = (OCTCommitCommentEvent *)event;
            
            NSString *octicon = [NSString octicon_iconStringForEnum:OCTIconCommentDiscussion];
            NSString *target  = [NSString stringWithFormat:@"%@@%@", concreteEvent.repositoryName, [concreteEvent.comment.commitSHA substringToIndex:7]];
            
            NSString *plainTitle = [NSString stringWithFormat:@"%@  %@ commented on commit %@", octicon, concreteEvent.actorLogin, target];
            
            NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:plainTitle attributes:boldTitleAttributes];
            
            [title addAttributes:octiconAttributes range:[plainTitle rangeOfString:octicon]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:concreteEvent.actorLogin]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:target]];
            
            NSAttributedString *detail = [[NSAttributedString alloc] initWithString:[@"\n" stringByAppendingString:concreteEvent.comment.body]
                                                                         attributes:normalTitleAttributes];
            
            [attributedString appendAttributedString:title];
            [attributedString appendAttributedString:detail];
        } else if ([event.type isEqualToString:@"CreateEvent"] || [event.type isEqualToString:@"DeleteEvent"]) {
            OCTRefEvent *concreteEvent = (OCTRefEvent *)event;
            
            NSString *action = @"";
            if (concreteEvent.eventType == OCTRefEventCreated) {
                action = @"created";
            } else if (concreteEvent.eventType == OCTRefEventDeleted) {
                action = @"deleted";
            }
            
            NSString *octicon = @"";
            NSString *type = @"";
            if (concreteEvent.refType == OCTRefTypeBranch) {
                octicon = [NSString octicon_iconStringForEnum:OCTIconGitBranch];
                type = @"branch";
            } else if (concreteEvent.refType == OCTRefTypeTag) {
                octicon = [NSString octicon_iconStringForEnum:OCTIconTag];
                type = @"tag";
            } else if (concreteEvent.refType == OCTRefTypeRepository) {
                octicon = [NSString octicon_iconStringForEnum:OCTIconRepo];
                type = @"repository";
            }
            
            NSString *refName = concreteEvent.refName ? [concreteEvent.refName stringByAppendingString:@" "] : @"";
            NSString *at = (concreteEvent.refType == OCTRefTypeBranch || concreteEvent.refType == OCTRefTypeTag ? @"at " : @"");
            
            NSString *plainTitle = [NSString stringWithFormat:@"%@  %@ %@ %@ %@%@%@", octicon, concreteEvent.actorLogin, action, type, refName, at, concreteEvent.repositoryName];
            
            NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:plainTitle attributes:normalTitleAttributes];
            
            [title addAttributes:octiconAttributes range:[plainTitle rangeOfString:octicon]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:concreteEvent.actorLogin]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:refName]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:concreteEvent.repositoryName]];
            
            [attributedString appendAttributedString:title];
        } else if ([event.type isEqualToString:@"ForkEvent"]) {
            OCTForkEvent *concreteEvent = (OCTForkEvent *)event;
            
            NSString *octicon = [NSString octicon_iconStringForEnum:OCTIconGitBranch];
            
            NSString *plainTitle = [NSString stringWithFormat:@"%@  %@ forked %@ to %@", octicon, concreteEvent.actorLogin, concreteEvent.repositoryName, concreteEvent.forkedRepositoryName];
            
            NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:plainTitle attributes:normalTitleAttributes];
            
            [title addAttributes:octiconAttributes range:[plainTitle rangeOfString:octicon]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:concreteEvent.actorLogin]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:concreteEvent.repositoryName]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:concreteEvent.forkedRepositoryName]];
            
            [attributedString appendAttributedString:title];
        } else if ([event.type isEqualToString:@"IssueCommentEvent"]) {
            OCTIssueCommentEvent *concreteEvent = (OCTIssueCommentEvent *)event;
            
            NSString *octicon = [NSString octicon_iconStringForEnum:OCTIconCommentDiscussion];
            NSString *target  = [NSString stringWithFormat:@"%@#%@", concreteEvent.repositoryName, [concreteEvent.issue.URL.absoluteString componentsSeparatedByString:@"/"].lastObject];
            
            NSString *plainTitle = [NSString stringWithFormat:@"%@  %@ commented on issue %@", octicon, concreteEvent.actorLogin, target];
            
            NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:plainTitle attributes:boldTitleAttributes];
            
            [title addAttributes:octiconAttributes range:[plainTitle rangeOfString:octicon]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:concreteEvent.actorLogin]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:target]];
            
            NSAttributedString *detail = [[NSAttributedString alloc] initWithString:[@"\n" stringByAppendingString:concreteEvent.comment.body]
                                                                         attributes:normalTitleAttributes];
            
            [attributedString appendAttributedString:title];
            [attributedString appendAttributedString:detail];
        } else if ([event.type isEqualToString:@"IssuesEvent"]) {
            OCTIssueEvent *concreteEvent = (OCTIssueEvent *)event;
            
            NSString *octicon = @"";
            NSString *action = @"";
            if (concreteEvent.action == OCTIssueActionOpened) {
                octicon = [NSString octicon_iconStringForEnum:OCTIconIssueOpened];
                action = @"opened";
            } else if (concreteEvent.action == OCTIssueActionClosed) {
                octicon = [NSString octicon_iconStringForEnum:OCTIconIssueClosed];
                action = @"closed";
            } else if (concreteEvent.action == OCTIssueActionReopened) {
                octicon = [NSString octicon_iconStringForEnum:OCTIconIssueReopened];
                action = @"reopened";
            } else if (concreteEvent.action == OCTIssueActionSynchronized) {
                action = @"synchronized";
            }
            
            NSString *issue = [NSString stringWithFormat:@"%@#%@", concreteEvent.repositoryName, [concreteEvent.issue.URL.absoluteString componentsSeparatedByString:@"/"].lastObject];
            NSString *plainTitle = [NSString stringWithFormat:@"%@  %@ %@ issue %@", octicon, concreteEvent.actorLogin, action, issue];
            
            NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:plainTitle attributes:boldTitleAttributes];
            
            [title addAttributes:octiconAttributes range:[plainTitle rangeOfString:octicon]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:concreteEvent.actorLogin]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:issue]];
            
            NSAttributedString *detail = [[NSAttributedString alloc] initWithString:[@"\n" stringByAppendingString:concreteEvent.issue.title]
                                                                         attributes:normalTitleAttributes];
            
            [attributedString appendAttributedString:title];
            [attributedString appendAttributedString:detail];
        } else if ([event.type isEqualToString:@"MemberEvent"]) {
            OCTMemberEvent *concreteEvent = (OCTMemberEvent *)event;
            
            NSString *octicon = [NSString octicon_iconStringForEnum:OCTIconOrganization];
            
            NSString *plainTitle = [NSString stringWithFormat:@"%@  %@ added %@ to %@", octicon, concreteEvent.actorLogin, concreteEvent.memberLogin, concreteEvent.repositoryName];
            
            NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:plainTitle attributes:normalTitleAttributes];
            
            [title addAttributes:octiconAttributes range:[plainTitle rangeOfString:octicon]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:concreteEvent.actorLogin]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:concreteEvent.memberLogin]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:concreteEvent.repositoryName]];
            
            [attributedString appendAttributedString:title];
        } else if ([event.type isEqualToString:@"PublicEvent"]) {
            OCTPublicEvent *concreteEvent = (OCTPublicEvent *)event;
            
            NSString *octicon = [NSString octicon_iconStringForEnum:OCTIconRepo];
            
            NSString *plainTitle = [NSString stringWithFormat:@"%@  %@ open sourced %@", octicon, concreteEvent.actorLogin, concreteEvent.repositoryName];
            
            NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:plainTitle attributes:normalTitleAttributes];
            
            [title addAttributes:octiconAttributes range:[plainTitle rangeOfString:octicon]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:concreteEvent.actorLogin]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:concreteEvent.repositoryName]];

            [attributedString appendAttributedString:title];
        } else if ([event.type isEqualToString:@"PullRequestEvent"]) {
            OCTPullRequestEvent *concreteEvent = (OCTPullRequestEvent *)event;
            
            NSString *action = @"";
            if (concreteEvent.action == OCTIssueActionOpened) {
                action = @"opened";
            } else if (concreteEvent.action == OCTIssueActionClosed) {
                action = @"closed";
            } else if (concreteEvent.action == OCTIssueActionReopened) {
                action = @"reopened";
            } else if (concreteEvent.action == OCTIssueActionSynchronized) {
                action = @"synchronized";
            }
            
            NSString *octicon = [NSString octicon_iconStringForEnum:OCTIconGitPullRequest];
            
            NSString *pullRequest = [NSString stringWithFormat:@"%@#%@", concreteEvent.repositoryName, [concreteEvent.pullRequest.URL.absoluteString componentsSeparatedByString:@"/"].lastObject];
            
            NSString *plainTitle = [NSString stringWithFormat:@"%@  %@ %@ pull request %@", octicon, concreteEvent.actorLogin, action, pullRequest];

            NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:plainTitle attributes:boldTitleAttributes];
            
            [title addAttributes:octiconAttributes range:[plainTitle rangeOfString:octicon]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:concreteEvent.actorLogin]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:pullRequest]];

            NSAttributedString *message = [[NSAttributedString alloc] initWithString:[@"\n" stringByAppendingString:concreteEvent.pullRequest.title]
                                                                          attributes:normalTitleAttributes];
            
            NSString *pullOcticon = [NSString octicon_iconStringForEnum:OCTIconGitCommit];
            
            NSString *commits   = @(concreteEvent.pullRequest.commits).stringValue;
            NSString *additions = @(concreteEvent.pullRequest.additions).stringValue;
            NSString *deletions = @(concreteEvent.pullRequest.deletions).stringValue;
            
            NSString *plainPullInfo = [NSString stringWithFormat:@"%@ %@ commits with %@ additions %@ deletions", pullOcticon, commits, additions, deletions];
            NSMutableAttributedString *pullInfo = [[NSMutableAttributedString alloc] initWithString:[@"\n" stringByAppendingString:plainPullInfo]
                                                                                         attributes:normalPullInfoAttributes];
            
            [pullInfo addAttributes:octiconAttributes range:[plainPullInfo rangeOfString:pullOcticon]];
            [pullInfo addAttributes:boldPullInfoAttributes range:[plainPullInfo rangeOfString:commits]];
            [pullInfo addAttributes:boldPullInfoAttributes range:[plainPullInfo rangeOfString:additions]];
            [pullInfo addAttributes:boldPullInfoAttributes range:[plainPullInfo rangeOfString:deletions]];

            [attributedString appendAttributedString:title];
            [attributedString appendAttributedString:message];
            [attributedString appendAttributedString:pullInfo];
        } else if ([event.type isEqualToString:@"PullRequestReviewCommentEvent"]) {
            OCTPullRequestCommentEvent *concreteEvent = (OCTPullRequestCommentEvent *)event;
            
            NSString *octicon = [NSString octicon_iconStringForEnum:OCTIconCommentDiscussion];
            NSString *target  = [NSString stringWithFormat:@"%@#%@", concreteEvent.repositoryName, [concreteEvent.comment.pullRequestAPIURL.absoluteString componentsSeparatedByString:@"/"].lastObject];
            
            NSString *plainTitle = [NSString stringWithFormat:@"%@  %@ commented on pull request %@", octicon, concreteEvent.actorLogin, target];
            
            NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:plainTitle attributes:boldTitleAttributes];
            
            [title addAttributes:octiconAttributes range:[plainTitle rangeOfString:octicon]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:concreteEvent.actorLogin]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:target]];

            NSAttributedString *detail = [[NSAttributedString alloc] initWithString:[@"\n" stringByAppendingString:concreteEvent.comment.body]
                                                                         attributes:normalTitleAttributes];
            
            [attributedString appendAttributedString:title];
            [attributedString appendAttributedString:detail];
        } else if ([event.type isEqualToString:@"PushEvent"]) {
            OCTPushEvent *concreteEvent = (OCTPushEvent *)event;
            
            NSString *octicon = [NSString octicon_iconStringForEnum:OCTIconGitCommit];
            
            NSString *plainTitle = [NSString stringWithFormat:@"%@  %@ pushed to %@ at %@", octicon, concreteEvent.actorLogin, concreteEvent.branchName, concreteEvent.repositoryName];
            
            NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:plainTitle attributes:boldTitleAttributes];
            
            [title addAttributes:octiconAttributes range:[plainTitle rangeOfString:octicon]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:concreteEvent.actorLogin]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:concreteEvent.branchName]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:concreteEvent.repositoryName]];
            NSMutableAttributedString *detail = [[NSMutableAttributedString alloc] init];
            
            for (NSDictionary *dictionary in concreteEvent.commits) {
                /*
                {
                    "sha": "6e4dc62cffe9f2d1b1484819936ee264dde36592",
                    "author": {
                        "email": "coderyi@foxmail.com",
                        "name": "coderyi"
                    },
                    "message": "增加iOS开发者coderyi的博客\n\n增加iOS开发者coderyi的博客",
                    "distinct": true,
                    "url": "https://api.github.com/repos/tangqiaoboy/iOSBlogCN/commits/6e4dc62cffe9f2d1b1484819936ee264dde36592"
                }
                */
                NSString *shortSHA = [dictionary[@"sha"] substringToIndex:7];
                NSString *plainCommit = [NSString stringWithFormat:@"\n%@ %@", shortSHA, dictionary[@"message"]];
               
                NSMutableAttributedString *commit = [[NSMutableAttributedString alloc] initWithString:plainCommit attributes:normalTitleAttributes];
                
                [commit addAttributes:tintedAttributes range:[plainCommit rangeOfString:shortSHA]];
                [detail appendAttributedString:commit];
            }
            
            [attributedString appendAttributedString:title];
            [attributedString appendAttributedString:detail];
        } else if ([event.type isEqualToString:@"WatchEvent"]) {
            OCTWatchEvent *concreteEvent = (OCTWatchEvent *)event;
            
            NSString *octicon = [NSString octicon_iconStringForIconIdentifier:@"Star"];
            
            NSString *plainTitle = [NSString stringWithFormat:@"%@  %@ starred %@", octicon, concreteEvent.actorLogin, concreteEvent.repositoryName];
            
            NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:plainTitle attributes:normalTitleAttributes];

            [title addAttributes:octiconAttributes range:[plainTitle rangeOfString:octicon]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:concreteEvent.actorLogin]];
            [title addAttributes:tintedAttributes range:[plainTitle rangeOfString:concreteEvent.repositoryName]];

            [attributedString appendAttributedString:title];
        } else {
            NSLog(@"Unknown event type: %@", event.type);
        }
        
        TTTTimeIntervalFormatter *timeIntervalFormatter = [TTTTimeIntervalFormatter new];
        timeIntervalFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        NSString *originalDate = [timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:event.date];
        
        NSAttributedString *date = [[NSAttributedString alloc] initWithString:[@"\n" stringByAppendingString:originalDate]
                                                                   attributes:timeAttributes];
        
        [attributedString appendAttributedString:date];
        
        self.attributedString = attributedString;
    }
    return self;
}

@end
