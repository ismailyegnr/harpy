import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harpy/components/common/animations/animation_constants.dart';
import 'package:harpy/components/timeline/common/bloc/timeline_bloc.dart';
import 'package:harpy/components/timeline/common/bloc/timeline_state.dart';
import 'package:harpy/components/timeline/common/widgets/no_timeline_tweets.dart';
import 'package:harpy/components/timeline/common/widgets/timeline_loading.dart';
import 'package:harpy/components/tweet/widgets/tweet_list.dart';

/// A callback for actions on a timeline, such as refreshing or loading more
/// tweets for a timeline.
typedef OnTimelineAction<T> = Future<void> Function(T);

/// Builds the [TweetList] for a [TimelineBloc].
class TweetTimeline<T extends TimelineBloc> extends StatelessWidget {
  const TweetTimeline({
    @required this.onRefresh,
    @required this.onLoadMore,
  });

  /// The callback for a [RefreshIndicator] for the [TweetList].
  final OnTimelineAction<T> onRefresh;

  /// The callback for a [LoadMoreList] for the [TweetList].
  final OnTimelineAction<T> onLoadMore;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<T, TimelineState>(
      builder: (BuildContext context, TimelineState state) {
        final T bloc = BlocProvider.of<T>(context);

        Widget child;

        if (bloc.showLoading) {
          child = const TimelineLoading();
        } else if (state is NoTweetsFoundState || bloc.showFailed) {
          child = NoTimelineTweets<T>(bloc, onRefresh: onRefresh);
        } else {
          child = TweetList(
            bloc.tweets,
            onRefresh: () => onRefresh(bloc),
            onLoadMore: () => onLoadMore(bloc),
            enableLoadMore: bloc.enableRequestMore,
          );
        }

        return AnimatedSwitcher(
          duration: kShortAnimationDuration,
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: child,
        );
      },
    );
  }
}