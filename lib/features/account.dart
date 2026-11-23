import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/state.dart';
import '../core/ui.dart';
import 'auth.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.state;
    final shortcuts = [
      (
        'Profile Information',
        'Change your account information',
        Icons.person,
        Screen.profile,
      ),
      ('Change Password', 'Change your password', Icons.lock, Screen.password),
      (
        'Payment Methods',
        'Add your credit & debit cards',
        Icons.credit_card,
        state.cards.isEmpty ? Screen.paymentEmpty : Screen.cards,
      ),
      (
        'Locations',
        'Add your delivery locations',
        Icons.location_on,
        Screen.locations,
      ),
      (
        'Add Social Account',
        'Add Facebook, Twitter, etc.',
        Icons.person_add_alt_1,
        Screen.socials,
      ),
      (
        'Refer to Friends',
        'Share GraBite with your friends',
        Icons.card_giftcard,
        Screen.refer,
      ),
    ];
    const notificationLabels = [
      'Push Notifications',
      'SMS Notifications',
      'Promotional Notifications',
    ];
    return PageFrame(
      tab: 3,
      body: ContentList([
        const IntroText(
          'Account Settings',
          'Manage your account, delivery locations and notifications.',
        ),
        space(16),
        for (final (title, subtitle, icon, route) in shortcuts)
          TintRow(
            title,
            subtitle: subtitle,
            icon: icon,
            strong: true,
            onTap: () => context.open(route),
          ),
        space(15),
        const SectionTitle('NOTIFICATIONS', size: 15),
        for (final (i, label) in notificationLabels.indexed)
          TintRow(
            label,
            subtitle: 'Manage this notification type',
            icon: Icons.notifications,
            strong: true,
            trailing: SizedBox(
              height: 26,
              child: Switch(
                value: state.notifications[i],
                onChanged: (value) => state.setNotification(i, value),
                activeThumbColor: white,
                activeTrackColor: red,
              ),
            ),
          ),
        space(15),
        const SectionTitle('MORE', size: 15),
        TintRow(
          'Rate Us',
          icon: Icons.star,
          strong: true,
          subtitle: 'Share feedback about GraBite',
          onTap: () => info(
            context,
            'Rate GraBite',
            'Thanks for trying this local GraBite demo.',
          ),
        ),
        TintRow(
          'FAQ',
          icon: Icons.help_outline,
          strong: true,
          subtitle: 'Frequently asked questions',
          onTap: () => info(
            context,
            'Frequently asked questions',
            'Browse restaurants, add items to the cart and place a demo order. Payments, location, messages and social sign-in are simulated.',
          ),
        ),
        TintRow(
          'Logout',
          icon: Icons.logout,
          strong: true,
          onTap: () => signOut(context),
        ),
      ]),
    );
  }

  Future<void> signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('LOG OUT'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    context.state.signOut();
    context.reset(Screen.signInActive);
  }
}

Future<void> info(BuildContext context, String title, String text) =>
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.changePassword = false});
  final bool changePassword;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final form = GlobalKey<FormState>();
  List<TextEditingController>? _fields;

  @override
  void dispose() {
    for (final controller in _fields ?? <TextEditingController>[]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.state;
    final changing = widget.changePassword;
    final values = changing
        ? ['', '', '']
        : [
            state.name,
            state.email,
            '',
            state.phone,
            state.addressOne,
            state.addressTwo,
          ];
    final fields = _fields ??= values
        .map((value) => TextEditingController(text: value))
        .toList();
    const profileLabels = [
      'Name',
      'Email',
      'Password',
      'Phone Number',
      'Address 1',
      'Address 2',
    ];
    const passwordLabels = [
      'Current Password',
      'New Password',
      'Confirm New Password',
    ];
    final labels = changing ? passwordLabels : profileLabels;
    return PageFrame(
      header: const ScreenHeader('Profile Settings'),
      footer: Foot(
        ActionButton(changing ? 'CHANGE PASSWORD' : 'CHANGE SETTINGS', () {
          if (!form.currentState!.validate()) return;
          if (changing) {
            context.close();
            context.showMessage('Password change preview completed.');
          } else {
            state.setProfile(
              fields[0].text.trim(),
              fields[1].text.trim(),
              fields[3].text.trim(),
              fields[4].text.trim(),
              fields[5].text.trim(),
            );
            FocusScope.of(context).unfocus();
            context.showMessage('Profile saved.');
          }
        }),
      ),
      body: Form(
        key: form,
        child: ContentList([
          IntroText(
            changing ? 'Change Password' : 'Edit Profile',
            changing
                ? 'Enter your current password and the new password in the fields below.'
                : 'You can edit your profile details in the fields below.',
          ),
          space(23),
          for (final (i, label) in labels.indexed) ...[
            if (!changing) ...[Text(label, style: type(12)), space(6)],
            if (!changing && i == 2)
              TintRow(
                'Password',
                onTap: () => context.open(Screen.password),
                trailing: const Icon(Icons.edit_note, color: coral, size: 20),
              )
            else
              Field(
                label,
                fields[i],
                highlight: true,
                secret: changing,
                action: i == labels.length - 1
                    ? TextInputAction.done
                    : TextInputAction.next,
                trailing: changing ? null : Icons.edit_note,
                keyboardType: changing
                    ? null
                    : i == 1
                    ? TextInputType.emailAddress
                    : i == 3
                    ? TextInputType.phone
                    : null,
                validator: changing
                    ? i == 2
                          ? (value) => value == fields[1].text
                                ? null
                                : 'Passwords must match'
                          : validPassword
                    : i == 1
                    ? (value) => value == null || value.isEmpty
                          ? null
                          : validEmail(value)
                    : i == 3
                    ? (value) => value == null || value.isEmpty
                          ? null
                          : validPhone(value)
                    : null,
              ),
            space(14),
          ],
        ]),
      ),
    );
  }
}

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key, this.empty = false});
  final bool empty;

  @override
  Widget build(BuildContext context) {
    final state = context.state;
    final showEmpty = empty && state.cards.isEmpty;
    return PageFrame(
      header: ScreenHeader(
        'Payment Methods',
        trailing: showEmpty
            ? null
            : IconButton(
                tooltip: 'Add card',
                icon: const Icon(Icons.add, color: red),
                onPressed: () => context.open(Screen.addCard),
              ),
      ),
      body: ContentList([
        if (showEmpty) ...[
          space(98),
          const Photo(
            'payment-art',
            height: 125,
            fit: BoxFit.contain,
            radius: 0,
          ),
          space(25),
          Text(
            'You haven’t added any\ncards yet.',
            textAlign: TextAlign.center,
            style: type(20, weight: FontWeight.w600),
          ),
          space(12),
          Text(
            'Add a demo credit or debit card to preview the payment flow.',
            textAlign: TextAlign.center,
            style: type(14, color: muted, height: 1.6),
          ),
          space(23),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: ActionButton(
              'ADD CREDIT CARD',
              () => context.open(Screen.addCard),
            ),
          ),
        ] else
          for (final (i, card) in state.cards.indexed)
            TintRow(
              card,
              subtitle: i == 0 ? 'Default Payment' : 'Not Default',
              strong: true,
              leading: PaymentBadge(card),
              onTap: () => manageCard(context, card, i),
            ),
      ]),
    );
  }

  Future<void> manageCard(BuildContext context, String card, int index) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(card),
        children: [
          if (index > 0)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'default'),
              child: const Text('Set as default'),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'remove'),
            child: const Text('Remove card'),
          ),
        ],
      ),
    );
    if (choice == null || !context.mounted) return;
    final state = context.state;
    state.cards.remove(card);
    if (choice == 'default') state.cards.insert(0, card);
    state.changed();
    if (state.cards.isEmpty && !empty) {
      context.open(Screen.paymentEmpty, replace: true);
    }
  }
}

class PaymentBadge extends StatelessWidget {
  const PaymentBadge(this.card, {super.key});
  final String card;

  @override
  Widget build(BuildContext context) {
    final mastercard = card.startsWith('MasterCard');
    return Container(
      width: 42,
      height: 32,
      decoration: BoxDecoration(
        color: mastercard ? ink : const Color(0xff006995),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: mastercard
          ? const SizedBox(
              width: 23,
              child: Stack(
                children: [
                  CircleAvatar(radius: 7, backgroundColor: Color(0xffed3823)),
                  Positioned(
                    left: 9,
                    child: CircleAvatar(
                      radius: 7,
                      backgroundColor: Color(0xccffa32e),
                    ),
                  ),
                ],
              ),
            )
          : Text(
              card.startsWith('PayPal')
                  ? 'P'
                  : card.startsWith('Visa')
                  ? 'VISA'
                  : 'CARD',
              style: type(10, color: white, weight: FontWeight.w700),
            ),
    );
  }
}

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key, this.preview = false});
  final bool preview;

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  late final number = TextEditingController(
    text: widget.preview ? '4343 4343 4343 4343' : '',
  );
  final expiry = TextEditingController();
  final cvc = TextEditingController();
  final form = GlobalKey<FormState>();

  @override
  void dispose() {
    number.dispose();
    expiry.dispose();
    cvc.dispose();
    super.dispose();
  }

  void fill() {
    number.text = '4242 4242 4242 4242';
    expiry.text = '12/30';
    cvc.text = '123';
  }

  void submit() {
    if (!form.currentState!.validate()) return;
    final state = context.state;
    final digits = number.text.replaceAll(RegExp(r'\D'), '');
    final brand = digits.startsWith('4')
        ? 'Visa'
        : digits.startsWith('5')
        ? 'MasterCard'
        : 'Card';
    final label = '$brand •••• ${digits.substring(digits.length - 4)}';
    state.cards.remove(label);
    state.cards.insert(0, label);
    state.changed();
    context.close();
    context.showMessage('Demo card added.');
  }

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      header: const ScreenHeader('Payment Method'),
      footer: Foot(
        Column(
          children: [
            ActionButton('ADD CARD', submit),
            space(12),
            ActionButton(
              'SCAN CARD',
              () async {
                final scanned = await Navigator.of(context).push<bool>(
                  MaterialPageRoute<bool>(builder: (_) => const ScanPage()),
                );
                if (scanned == true && mounted) fill();
              },
              light: true,
              icon: Icons.document_scanner,
            ),
          ],
        ),
      ),
      body: Form(
        key: form,
        child: ContentList([
          space(7),
          const IntroText(
            'Add your payment method',
            'Preview the payment form with sample card details.',
          ),
          space(25),
          Field(
            '4343 4343 4343 4343',
            number,
            highlight: true,
            icon: Icons.credit_card,
            keyboardType: TextInputType.number,
            maxLength: 23,
            action: TextInputAction.next,
            validator: (value) =>
                (value ?? '').replaceAll(RegExp(r'\D'), '').length == 16
                ? null
                : 'Enter 16 digits',
          ),
          space(13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Field(
                  'MM/YY',
                  expiry,
                  highlight: true,
                  maxLength: 5,
                  action: TextInputAction.next,
                  validator: (value) =>
                      RegExp(r'^(0[1-9]|1[0-2])/[0-9]{2}$')
                          .hasMatch(value ?? '')
                      ? null
                      : 'Use MM/YY',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Field(
                  'CVC',
                  cvc,
                  highlight: true,
                  secret: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      RegExp(r'^\d{3,4}$').hasMatch(value ?? '')
                      ? null
                      : 'Enter 3–4 digits',
                ),
              ),
            ],
          ),
          space(8),
          Align(
            alignment: Alignment.centerLeft,
            child: MiniAction('Use demo card', fill, background: false),
          ),
        ]),
      ),
    );
  }
}

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Photo('scan-background', radius: 0),
          const ColoredBox(color: Color(0x8c16191e)),
          SafeArea(
            child: Column(
              children: [
                const ScreenHeader(''),
                Expanded(
                  child: ContentList([
                    space(58),
                    Center(
                      child: Text(
                        'Payment Time.',
                        textAlign: TextAlign.center,
                        style: type(27, color: coral, weight: FontWeight.w700),
                      ),
                    ),
                    space(19),
                    Text(
                      'Align the card in the frame to preview the scanning experience.',
                      textAlign: TextAlign.center,
                      style: type(15, color: white, height: 1.55),
                    ),
                    space(31),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: red, width: 2),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Photo(
                          'scan-card',
                          width: 224,
                          height: 132,
                          radius: 7,
                        ),
                      ),
                    ),
                  ]),
                ),
                Foot(
                  ActionButton(
                    'USE DEMO CARD',
                    () => Navigator.pop(context, true),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SocialAccountsPage extends StatelessWidget {
  const SocialAccountsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.state;
    return PageFrame(
      header: const ScreenHeader('Add Social Accounts'),
      body: ContentList([
        space(10),
        const IntroText(
          'Add Social Accounts',
          'Add your social accounts for more security and fun with Foodor.',
        ),
        space(26),
        SocialButtons(
          all: true,
          sideBySide: true,
          connected: state.socialAccounts,
          onTap: state.toggleSocial,
        ),
      ]),
    );
  }
}

class ReferralPage extends StatelessWidget {
  const ReferralPage({super.key, this.share = false});
  final bool share;
  static const link = 'https://example.com/grabite';

  Future<void> copy(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: link));
    if (context.mounted) context.showMessage('Demo referral link copied.');
  }

  @override
  Widget build(BuildContext context) {
    final content = PageFrame(
      header: const ScreenHeader('Refer to Friends'),
      footer: Foot(
        Column(
          children: [
            ActionButton('EMAIL', () => context.open(Screen.share)),
            space(12),
            ActionButton(
              'OTHERS',
              () => context.open(Screen.share),
              light: true,
            ),
          ],
        ),
      ),
      body: ContentList([
        space(34),
        const Photo('gift-art', height: 145, fit: BoxFit.contain, radius: 0),
        space(22),
        Text(
          'Refer a Friend, Get \$10',
          textAlign: TextAlign.center,
          style: type(22, weight: FontWeight.w700),
        ),
        space(12),
        Text(
          'Get \$10 in credits when someone signs up using your referral link.',
          textAlign: TextAlign.center,
          style: type(14, color: muted, height: 1.6),
        ),
        space(23),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23),
          child: TintRow(
            link,
            icon: Icons.reply,
            onTap: () => copy(context),
            trailing: const Icon(Icons.copy, size: 17, color: coral),
          ),
        ),
      ]),
    );
    if (!share) return content;
    return Stack(
      children: [
        IgnorePointer(child: content),
        Positioned.fill(
          child: GestureDetector(
            onTap: context.close,
            child: const ColoredBox(color: Color(0x70000000)),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Material(
                  color: white,
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.all(17),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 36,
                          child: Divider(color: coral, thickness: 3),
                        ),
                        space(10),
                        const SectionTitle('Share referral link', size: 17),
                        TintRow(
                          link,
                          icon: Icons.link,
                          strong: true,
                          onTap: () => copy(context),
                        ),
                        space(11),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            for (final (label, icon) in [
                              ('Message', Icons.message),
                              ('Mail', Icons.email),
                              ('Copy', Icons.copy),
                            ])
                              Flexible(
                                child: Column(
                                  children: [
                                    IconButton.filledTonal(
                                      tooltip: label,
                                      onPressed: () => copy(context),
                                      icon: Icon(icon, color: red),
                                    ),
                                    Text(label, style: type(11)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        space(21),
                        ActionButton('CANCEL', context.close, light: true),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
