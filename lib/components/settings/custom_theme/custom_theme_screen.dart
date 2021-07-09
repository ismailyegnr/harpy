import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:harpy/components/components.dart';
import 'package:harpy/harpy.dart';
import 'package:harpy/harpy_widgets/harpy_widgets.dart';
import 'package:harpy/misc/misc.dart';
import 'package:provider/provider.dart';

/// The custom theme screen for editing existing custom themes and creating
/// new custom themes.
class CustomThemeScreen extends StatelessWidget {
  const CustomThemeScreen({
    required this.themeData,
    required this.themeId,
  });

  /// The [HarpyThemeData] for the theme customization.
  ///
  /// When creating a new custom theme, this will be initialized with the
  /// currently active theme.
  /// When editing an existing custom theme, this will be set to the custom
  /// theme data.
  final HarpyThemeData? themeData;

  /// The id of this custom theme, starting at 10 for the first custom theme.
  ///
  /// When creating a new custom theme, this will be the next available id.
  /// When editing an existing custom theme, this will be the id of the custom
  /// theme.
  final int? themeId;

  static const String route = 'custom_theme_screen';

  Future<bool> _onWillPop(
    BuildContext context,
    HarpyTheme harpyTheme,
    CustomThemeBloc customThemeBloc,
  ) async {
    var pop = true;

    if (customThemeBloc.canSaveTheme) {
      // ask to discard changes before exiting customization

      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => const HarpyDialog(
          title: Text('discard changes?'),
          actions: <DialogAction<bool>>[
            DialogAction<bool>(
              result: false,
              text: 'cancel',
            ),
            DialogAction<bool>(
              result: true,
              text: 'discard',
            ),
          ],
        ),
      );

      pop = discard != null && discard;
    }

    if (pop) {
      // reset the system ui
      updateSystemUi(harpyTheme);
      return true;
    } else {
      return false;
    }
  }

  Widget _buildSaveAction(CustomThemeBloc customThemeBloc) {
    return HarpyButton.flat(
      padding: const EdgeInsets.all(16),
      icon: const Icon(FeatherIcons.check),
      onTap: customThemeBloc.canSaveTheme
          ? () => customThemeBloc.add(const SaveCustomTheme())
          : null,
    );
  }

  Widget _buildBody(ConfigState config, CustomThemeBloc customThemeBloc) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: config.edgeInsetsSymmetric(vertical: true),
            children: <Widget>[
              if (Harpy.isFree) ...<Widget>[
                const BuyProText(),
                defaultVerticalSpacer,
              ],
              ThemeNameSelection(customThemeBloc),
              SizedBox(height: config.paddingValue * 2),
              AccentColorSelection(customThemeBloc),
              SizedBox(height: config.paddingValue * 2),
              BackgroundColorSelection(customThemeBloc),
              SizedBox(height: config.paddingValue * 2),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.watch<ThemeBloc>();
    final harpyTheme = context.watch<HarpyTheme>();

    return BlocProvider<CustomThemeBloc>(
      create: (_) => CustomThemeBloc(
        themeData: crow, // todo
        themeId: themeId,
        themeBloc: themeBloc,
      ),
      child: BlocBuilder<CustomThemeBloc, CustomThemeState>(
        builder: (context, state) {
          final config = context.watch<ConfigBloc>().state;
          final customThemeBloc = CustomThemeBloc.of(context);
          final customHarpyTheme = customThemeBloc.harpyTheme;

          return Theme(
            data: customHarpyTheme.themeData,
            child: Builder(
              builder: (context) => WillPopScope(
                onWillPop: () => _onWillPop(
                  context,
                  harpyTheme,
                  customThemeBloc,
                ),
                child: HarpyScaffold(
                  backgroundColors: customHarpyTheme.backgroundColors,
                  actions: <Widget>[
                    _buildSaveAction(customThemeBloc),
                  ],
                  title: 'theme customization',
                  buildSafeArea: true,
                  body: _buildBody(config, customThemeBloc),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
