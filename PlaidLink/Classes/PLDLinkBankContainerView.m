//
//  PLDLinkBankContainerView.m
//  Plaid
//
//  Created by Simon Levy on 10/20/15.
//  Copyright © 2015 Vouch Financial, Inc. All rights reserved.
//

#import "PLDLinkBankContainerView.h"

#import "PLDLinkBankTileView.h"
#import "PLDLinkBankMFAExplainerView.h"

#import "PLDInstitution.h"

static CGFloat const kContentPadding = 8.0;
static CGFloat const kDefaultContentHeight = 200;

@implementation PLDLinkBankContainerView {
  UIView *_currentContent;
  CAShapeLayer * _maskBehindTile;
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.clipsToBounds = NO;
    self.alwaysBounceVertical = YES;
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    _bankTileView = [[PLDLinkBankTileView alloc] initWithFrame:CGRectZero];
    // Don't add it as a subview yet.

    _contentContainer = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:_contentContainer];

    _maskBehindTile = [[CAShapeLayer alloc] init];
  }
  return self;
}

- (void)setBankTileView:(PLDLinkBankTileView *)bankTileView {
  [bankTileView removeFromSuperview];
  _bankTileView = bankTileView;
  [self insertSubview:_bankTileView aboveSubview:_contentContainer];
  _contentContainer.backgroundColor = _bankTileView.institution.backgroundColor;
}

- (void)setCurrentContentView:(UIView *)contentView {
  if (_currentContent) {
    [self animateCurrentContentOutWithCompletion:^(BOOL finished) {
      [_currentContent removeFromSuperview];
      _currentContent = contentView;
      [_contentContainer addSubview:_currentContent];
      [self animateCurrentContentIn:^(BOOL finished) {
        [_currentContent becomeFirstResponder];
      }];
    }];
  } else {
    [_currentContent removeFromSuperview];
    _currentContent = contentView;
    [_contentContainer addSubview:_currentContent];
  }
}

- (void)layoutSubviews {
  [super layoutSubviews];

  CGRect bounds = self.bounds;

  _bankTileView.frame =
      CGRectMake(kContentPadding, 0, bounds.size.width - kContentPadding * 2, bounds.size.height / 4);
  _contentContainer.frame = CGRectMake(kContentPadding,
                                       CGRectGetMaxY(_bankTileView.frame),
                                       self.bounds.size.width - 2 * kContentPadding,
                                       kDefaultContentHeight);
  if (_currentContent) {
    _currentContent.frame = _contentContainer.bounds;
    [_currentContent sizeToFit];
    CGRect containerFrame = _contentContainer.frame;
    containerFrame.size.height = _currentContent.bounds.size.height;
    _contentContainer.frame = containerFrame;
  }

  UIBezierPath *path =
      [UIBezierPath bezierPathWithRoundedRect:_contentContainer.bounds
                            byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                  cornerRadii:CGSizeMake(8, 8)];
  CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
  maskLayer.frame = _contentContainer.bounds;
  maskLayer.path  = path.CGPath;
  _contentContainer.layer.mask = maskLayer;

  if (!CGAffineTransformEqualToTransform(_contentContainer.transform, CGAffineTransformIdentity)) {
    _maskBehindTile.frame = self.frame;
    _maskBehindTile.path =
        [UIBezierPath bezierPathWithRoundedRect:CGRectMake(kContentPadding,
                                                           0,
                                                           self.bounds.size.width - 2 * kContentPadding,
                                                           self.bounds.size.height)
                                   cornerRadius:8.0].CGPath;
    self.layer.mask = _maskBehindTile;
  }

  self.contentSize = CGSizeMake(bounds.size.width, CGRectGetMaxY(_contentContainer.frame));
}

- (void)animateCurrentContentOutWithCompletion:(void (^ __nullable)(BOOL finished))completion {
  CGAffineTransform transform = CGAffineTransformMakeTranslation(-CGRectGetWidth(self.bounds), 0);
  [UIView animateWithDuration:0.25
                        delay:0
                      options:UIViewAnimationOptionCurveEaseIn
                   animations:^{
                     _currentContent.alpha = 0;
                     _currentContent.transform = transform;
                   } completion:completion];
}

- (void)animateCurrentContentIn:(void (^ __nullable)(BOOL finished))completion {
  _currentContent.frame = _contentContainer.bounds;
  [_currentContent layoutSubviews];
  _currentContent.alpha = 0;
  _currentContent.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.bounds), 0);
  [UIView animateWithDuration:0.25
                        delay:0
                      options:UIViewAnimationOptionCurveEaseOut
                   animations:^{
                     _currentContent.alpha = 1;
                     _currentContent.transform = CGAffineTransformIdentity;
                     [self layoutSubviews];
                   } completion:completion];
}

@end
