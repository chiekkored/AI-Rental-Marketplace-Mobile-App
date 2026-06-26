import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/verified_name.common.dart';
import 'package:lend/utilities/enums/eligibility.enum.dart';
import 'package:lend/utilities/theme/lnd_app_theme.dart';

void main() {
  testWidgets('LNDVerifiedName renders no badge for none', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: LNDAppTheme.light,
        home: const Scaffold(
          body: LNDVerifiedName(
            name: 'Ada Lovelace',
            verificationLevel: VerificationLevel.none,
          ),
        ),
      ),
    );

    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(
      find.byKey(const ValueKey(LNDVerificationBadge.basicAsset)),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey(LNDVerificationBadge.fullAsset)),
      findsNothing,
    );
  });

  testWidgets('LNDVerifiedName renders the basic verification SVG', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: LNDAppTheme.light,
        home: const Scaffold(
          body: LNDVerifiedName(
            name: 'Grace Hopper',
            verificationLevel: VerificationLevel.basic,
          ),
        ),
      ),
    );

    expect(find.text('Grace Hopper'), findsOneWidget);
    expect(
      find.byKey(const ValueKey(LNDVerificationBadge.basicAsset)),
      findsOneWidget,
    );
  });

  testWidgets('LNDVerifiedName renders the full verification SVG', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: LNDAppTheme.light,
        home: const Scaffold(
          body: LNDVerifiedName(
            name: 'Katherine Johnson',
            verificationLevel: VerificationLevel.full,
          ),
        ),
      ),
    );

    expect(find.text('Katherine Johnson'), findsOneWidget);
    expect(
      find.byKey(const ValueKey(LNDVerificationBadge.fullAsset)),
      findsOneWidget,
    );
  });

  testWidgets('LNDVerifiedName renders the business badge', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: LNDAppTheme.light,
        home: const Scaffold(
          body: LNDVerifiedName(
            name: 'Jamie Rentals OPC',
            showBusinessBadge: true,
          ),
        ),
      ),
    );

    expect(find.text('Jamie Rentals OPC'), findsOneWidget);
    expect(find.byKey(LNDBusinessNameBadge.badgeKey), findsOneWidget);
  });

  testWidgets('LNDVerifiedName renders the founding owner badge', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: LNDAppTheme.light,
        home: const Scaffold(
          body: LNDVerifiedName(
            name: 'Jamie Rentals OPC',
            showFoundingOwnerBadge: true,
          ),
        ),
      ),
    );

    expect(find.text('Jamie Rentals OPC'), findsOneWidget);
    expect(find.byKey(LNDFoundingOwnerBadge.badgeKey), findsOneWidget);
  });

  testWidgets('LNDVerifiedName business badge replaces verification badge', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: LNDAppTheme.light,
        home: const Scaffold(
          body: LNDVerifiedName(
            name: 'Jamie Rentals OPC',
            verificationLevel: VerificationLevel.full,
            showBusinessBadge: true,
          ),
        ),
      ),
    );

    expect(find.byKey(LNDBusinessNameBadge.badgeKey), findsOneWidget);
    expect(
      find.byKey(const ValueKey(LNDVerificationBadge.fullAsset)),
      findsNothing,
    );
  });

  testWidgets(
    'LNDVerifiedName founding owner badge renders alongside the primary badge',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          theme: LNDAppTheme.light,
          home: const Scaffold(
            body: LNDVerifiedName(
              name: 'Jamie Rentals OPC',
              verificationLevel: VerificationLevel.full,
              showBusinessBadge: true,
              showFoundingOwnerBadge: true,
            ),
          ),
        ),
      );

      expect(find.byKey(LNDFoundingOwnerBadge.badgeKey), findsOneWidget);
      expect(find.byKey(LNDBusinessNameBadge.badgeKey), findsOneWidget);
      expect(
        find.byKey(const ValueKey(LNDVerificationBadge.fullAsset)),
        findsNothing,
      );
    },
  );

  testWidgets('LNDVerifiedName constrains long names before the badge', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: LNDAppTheme.light,
        home: const Scaffold(
          body: SizedBox(
            width: 120.0,
            child: LNDVerifiedName(
              name: 'A very long verified display name',
              verificationLevel: VerificationLevel.full,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey(LNDVerificationBadge.fullAsset)),
      findsOneWidget,
    );
  });

  testWidgets('business badge opens badge information sheet', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: LNDAppTheme.light,
        home: const Scaffold(
          body: LNDVerifiedName(
            name: 'Jamie Rentals OPC',
            showBusinessBadge: true,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(LNDBusinessNameBadge.badgeKey));
    await tester.pumpAndSettle();

    expect(find.text('Business name'), findsOneWidget);
    expect(
      find.text(
        'This owner is showing an approved business name on their listings.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('basic verification badge opens badge information sheet', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: LNDAppTheme.light,
        home: const Scaffold(
          body: LNDVerifiedName(
            name: 'Grace Hopper',
            verificationLevel: VerificationLevel.basic,
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey(LNDVerificationBadge.basicAsset)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Basic verified'), findsOneWidget);
    expect(
      find.text(
        'This user has completed Lend’s basic verification requirements.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('full verification badge opens badge information sheet', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: LNDAppTheme.light,
        home: const Scaffold(
          body: LNDVerifiedName(
            name: 'Katherine Johnson',
            verificationLevel: VerificationLevel.full,
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey(LNDVerificationBadge.fullAsset)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fully verified'), findsOneWidget);
    expect(
      find.text(
        'This user has completed Lend’s full verification requirements for higher-trust marketplace actions.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('founding owner badge opens badge information sheet', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: LNDAppTheme.light,
        home: const Scaffold(
          body: LNDVerifiedName(
            name: 'Jamie Rentals OPC',
            showFoundingOwnerBadge: true,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(LNDFoundingOwnerBadge.badgeKey));
    await tester.pumpAndSettle();

    expect(find.text('Founding Owner'), findsOneWidget);
    expect(
      find.text(
        'This owner joined through Lend’s early owner invite program and helped seed the marketplace with early listings.',
      ),
      findsOneWidget,
    );
  });
}
