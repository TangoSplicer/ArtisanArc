import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared app bar for Personal Edition screens.
///
/// It always offers a clear route out of the current screen: Back returns to
/// the prior route when one exists; otherwise it returns to the Home hub. A
/// Home action remains available from every feature screen.
class PersonalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final PreferredSizeWidget? bottom;
  final bool showHomeAction;

  const PersonalAppBar({
    super.key,
    required this.title,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.bottom,
    this.showHomeAction = true,
  });

  void _goBackOrHome(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/home');
    }
  }

  bool _isHomeRoute(BuildContext context) {
    try {
      return GoRouterState.of(context).matchedLocation == '/home';
    } on GoError {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHome = _isHomeRoute(context);
    final canPop = Navigator.of(context).canPop();
    final mergedActions = <Widget>[
      ...?actions,
      if (showHomeAction && !isHome && canPop)
        IconButton(
          tooltip: 'Home',
          icon: const Icon(Icons.home_outlined),
          onPressed: () => context.go('/home'),
        ),
    ];

    return AppBar(
      title: title,
      automaticallyImplyLeading: false,
      leading: isHome
          ? null
          : IconButton(
              tooltip: canPop ? 'Back' : 'Home',
              icon: Icon(canPop ? Icons.arrow_back : Icons.home_outlined),
              onPressed: () => _goBackOrHome(context),
            ),
      actions: mergedActions.isEmpty ? null : mergedActions,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}
