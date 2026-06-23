import 'package:flutter/material.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    this.portalLabel = 'Emergency Response System',
    this.showBackButton = false,
    super.key,
  });

  static const green = Color(0xFF006B2D);
  static const gold = Color(0xFFF2B705);

  final String title;
  final String subtitle;
  final String portalLabel;
  final bool showBackButton;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final authTheme = baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: green,
        secondary: gold,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFD3D8D3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFD3D8D3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: green, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: green,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: green),
      ),
    );

    return Theme(
      data: authTheme,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAF8),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFD8DDD8)),
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 18,
                        offset: Offset(0, 7),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showBackButton)
                          Container(
                            height: 52,
                            color: green,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: IconButton(
                                    onPressed: () =>
                                        Navigator.of(context).maybePop(),
                                    color: Colors.white,
                                    icon: const Icon(Icons.arrow_back),
                                  ),
                                ),
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(28, 30, 28, 34),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Icon(
                                Icons.shield_rounded,
                                color: green,
                                size: 68,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'SAGIP',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: green,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                portalLabel,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 28),
                              if (!showBackButton) ...[
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                              ],
                              Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF616861),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 24),
                              child,
                            ],
                          ),
                        ),
                        Container(height: 6, color: gold),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
