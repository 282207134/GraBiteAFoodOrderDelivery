import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/state.dart';
import '../core/ui.dart';
import '../data/catalog.dart';

class SplashPage extends StatefulWidget {
  const SplashPage(this.screen, {super.key, this.hold = false});
  final Screen screen;
  final bool hold;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    if (!widget.hold) {
      timer = Timer(const Duration(milliseconds: 1000), proceed);
    }
  }

  void proceed() {
    timer?.cancel();
    context.reset(context.state.loggedIn ? Screen.home : Screen.introOne);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final background = switch (widget.screen) {
      Screen.splashCoral => coral,
      Screen.splashBlack => Colors.black,
      _ => white,
    };
    final textColor = background == white ? coral : white;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: background == white
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Center(
            child: GestureDetector(
              onTap: proceed,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Photo(
                    widget.screen == Screen.splashCoral ? 'logo-light' : 'logo',
                    height: 132,
                    width: 132,
                    radius: 15,
                  ),
                  space(10),
                  Text(
                    'GraBite',
                    style: type(34, color: textColor, weight: FontWeight.w600),
                  ),
                  space(24),
                  Text(
                    'We believe in tastes\nand fast deliveries',
                    textAlign: TextAlign.center,
                    style: type(
                      18,
                      color: textColor,
                      weight: FontWeight.w600,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WalkthroughPage extends StatefulWidget {
  const WalkthroughPage(this.start, {super.key});
  final int start;

  @override
  State<WalkthroughPage> createState() => _WalkthroughPageState();
}

class _WalkthroughPageState extends State<WalkthroughPage> {
  late final pager = PageController(initialPage: widget.start);
  late int current = widget.start;

  static const slides = [
    (
      'All your favorites',
      'Order from the best local restaurants with easy, on-demand delivery.',
    ),
    (
      'Free delivery offers',
      'Free delivery for new customers via Apple Pay and others payment methods.',
    ),
    (
      'Choose your food',
      'Easily find your type of food craving and you’ll get delivery in wide range.',
    ),
  ];

  @override
  void dispose() {
    pager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      topInset: 0,
      body: PageView.builder(
        controller: pager,
        itemCount: slides.length,
        onPageChanged: (value) => setState(() => current = value),
        itemBuilder: (context, index) {
          final (title, description) = slides[index];
          return LayoutBuilder(
            builder: (context, layout) {
              final height = layout.maxHeight;
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: gutter),
                children: [
                  space(height * .115),
                  Photo(
                    'onboard-${index + 1}',
                    height: height * .37,
                    fit: BoxFit.contain,
                    radius: 0,
                  ),
                  space(height * .12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: type(
                            25,
                            color: coral,
                            weight: FontWeight.w600,
                          ),
                        ),
                        space(10),
                        Text(
                          description,
                          textAlign: TextAlign.center,
                          style: type(14, color: muted, height: 1.55),
                        ),
                      ],
                    ),
                  ),
                  space(height * .071),
                  ActionButton('GET STARTED', () {
                    if (index == slides.length - 1) {
                      context.open(Screen.signInActive);
                    } else {
                      pager.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    }
                  }),
                  space(26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      slides.length,
                      (dot) => InkWell(
                        onTap: () => pager.animateToPage(
                          dot,
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            height: 5,
                            width: dot == current ? 18 : 7,
                            decoration: BoxDecoration(
                              color: dot == current
                                  ? red
                                  : const Color(0xffffd6cd),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

String? requiredText(String? value) =>
    value == null || value.trim().isEmpty ? 'Please complete this field' : null;
String? validEmail(String? value) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value?.trim() ?? '')
    ? null
    : 'Enter a valid email address';
String? validPhone(String? value) =>
    (value ?? '').replaceAll(RegExp(r'\D'), '').length >= 7
    ? null
    : 'Enter a valid phone number';
String? validPassword(String? value) =>
    (value?.length ?? 0) >= 6 ? null : 'Use at least 6 characters';
String? validIdentity(String? value) =>
    (value?.contains('@') ?? false) ? validEmail(value) : validPhone(value);

class SignInPage extends StatefulWidget {
  const SignInPage({super.key, this.full = true, this.preview = false});
  final bool full, preview;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final form = GlobalKey<FormState>();
  final identity = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    identity.dispose();
    password.dispose();
    super.dispose();
  }

  void submit() {
    if (!form.currentState!.validate()) return;
    context.state.signIn(identity.text.trim());
    context.reset(Screen.address);
  }

  @override
  Widget build(BuildContext context) {
    final full = widget.full;
    return PageFrame(
      header: const ScreenHeader('Sign In'),
      body: Form(
        key: form,
        child: ContentList([
          space(8),
          IntroText(
            'Welcome',
            full
                ? 'Enter your Phone number or Email address for sign in. Enjoy your food :)'
                : 'Please, enter your phone number or email to sign in.',
          ),
          space(22),
          Field(
            'Email / Phone Number',
            identity,
            highlight: full,
            validator: validIdentity,
            action: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            trailing: Icons.phone_android,
          ),
          space(12),
          Field(
            'Password',
            password,
            highlight: full,
            secret: true,
            validator: validPassword,
            onSubmitted: (_) => submit(),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: MiniAction(
              'Forget Password?',
              () => context.open(Screen.forgot),
              background: false,
            ),
          ),
          space(13),
          ActionButton('SIGN IN', submit),
          if (full) ...[
            space(20),
            Center(
              child: Text(
                'OR',
                style: type(12, color: coral, weight: FontWeight.w600),
              ),
            ),
            space(18),
            SocialButtons(
              onTap: (provider) =>
                  context.showMessage('$provider sign-in is a demo preview.'),
            ),
            space(16),
            Center(
              child: MiniAction(
                'Use phone number',
                () => context.open(Screen.phone),
                background: false,
              ),
            ),
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Don’t have an account? Let’s',
                    style: type(12, color: muted),
                  ),
                  MiniAction(
                    'Register',
                    () => context.open(Screen.register),
                    background: false,
                  ),
                ],
              ),
            ),
          ] else if (!widget.preview) ...[
            space(14),
            Center(
              child: MiniAction(
                'More sign-in options',
                () => context.open(Screen.signInActive, replace: true),
                background: false,
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

class SocialButtons extends StatelessWidget {
  const SocialButtons({
    super.key,
    required this.onTap,
    this.sideBySide = false,
    this.all = false,
    this.connected = const {},
  });
  final ValueChanged<String> onTap;
  final bool sideBySide, all;
  final Set<String> connected;

  static const providers = [
    ('Google', Color(0xfff9e9e7), Color(0xffb94b3a)),
    ('Facebook', Color(0xffe9eff9), Color(0xff355894)),
    ('Instagram', Color(0xfffae8f2), Color(0xffbc376c)),
    ('TikTok', Color(0xffececec), Color(0xff242424)),
    ('Pinterest', Color(0xfffae6e9), Color(0xffae2543)),
    ('Twitter', Color(0xffe6f1fc), Color(0xff1a6d9d)),
  ];

  Widget buildButton(int index) {
    final (name, background, color) = providers[index];
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        onPressed: () => onTap(name),
        style: TextButton.styleFrom(
          backgroundColor: background,
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Text(
          '${name.toUpperCase()}${connected.contains(name) ? ' ✓' : ''}',
          style: type(
            12,
            color: color,
            weight: FontWeight.w700,
          ).copyWith(letterSpacing: 1.6),
          maxLines: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!sideBySide) {
      return Column(children: [buildButton(0), space(12), buildButton(1)]);
    }
    return Column(
      children: [
        for (var index = 0; index < (all ? 6 : 2); index += 2) ...[
          if (index > 0) space(14),
          Row(
            children: [
              Expanded(child: buildButton(index)),
              const SizedBox(width: 16),
              Expanded(child: buildButton(index + 1)),
            ],
          ),
        ],
      ],
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.active = false});
  final bool active;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late bool accepted = widget.active;
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = accepted || widget.active;
    return PageFrame(
      header: const ScreenHeader('Create Account'),
      body: Form(
        key: form,
        child: ContentList([
          space(8),
          const IntroText(
            'Create Account',
            'Enter your details below to create an\naccount.',
          ),
          space(20),
          Field(
            'Full Name',
            name,
            highlight: active,
            validator: requiredText,
            action: TextInputAction.next,
          ),
          space(12),
          Field(
            'Email Address',
            email,
            highlight: active,
            validator: validEmail,
            keyboardType: TextInputType.emailAddress,
            action: TextInputAction.next,
          ),
          space(12),
          Field(
            'Password',
            password,
            highlight: active,
            secret: true,
            validator: validPassword,
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              'I agree with Terms & Conditions',
              style: type(12, color: red),
            ),
            value: accepted,
            onChanged: (value) => setState(() => accepted = value ?? false),
          ),
          space(8),
          ActionButton('SIGN UP', () {
            if (!form.currentState!.validate()) return;
            if (!accepted) {
              context.showMessage('Accept the terms to continue.');
              return;
            }
            context.state.signIn(email.text.trim(), fullName: name.text.trim());
            context.reset(Screen.address);
          }),
          space(19),
          Center(
            child: Text('OR', style: type(12, color: coral)),
          ),
          space(17),
          SocialButtons(
            sideBySide: true,
            onTap: (name) =>
                context.showMessage('$name sign-up is a demo preview.'),
          ),
          space(42),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Already have an account? Let’s',
                  style: type(12, color: muted),
                ),
                MiniAction(
                  'Login',
                  () => context.open(Screen.signInActive, replace: true),
                  background: false,
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, this.sent = false});
  final bool sent;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final email = TextEditingController();
  final form = GlobalKey<FormState>();

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  void submit() {
    if (!form.currentState!.validate()) return;
    context.state.resetEmail = email.text.trim();
    FocusScope.of(context).unfocus();
    context.open(Screen.resetSent);
  }

  @override
  Widget build(BuildContext context) {
    final address = context.state.resetEmail;
    return PageFrame(
      header: const ScreenHeader('Forgot Password'),
      body: Form(
        key: form,
        child: ContentList([
          space(8),
          IntroText(
            widget.sent ? 'Reset email sent' : 'Forgot Password',
            widget.sent
                ? 'Reset instructions were prepared for $address. This is a local preview.'
                : 'Enter your email address and we will send you an email with instructions.',
          ),
          space(22),
          if (!widget.sent) ...[
            Field(
              'Email Address',
              email,
              highlight: true,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              trailing: Icons.phone_android,
              validator: validEmail,
              onSubmitted: (_) => submit(),
            ),
            space(13),
          ],
          ActionButton(
            widget.sent ? 'SEND AGAIN' : 'RESET PASSWORD',
            widget.sent
                ? () => context.showMessage(
                    'Reset instructions prepared for $address.',
                  )
                : submit,
          ),
        ]),
      ),
    );
  }
}

class PhonePage extends StatefulWidget {
  const PhonePage({
    super.key,
    this.active = false,
    this.verify = false,
    this.preview = false,
  });
  final bool active, verify, preview;

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  late final value = TextEditingController(
    text: widget.preview && widget.active
        ? (widget.verify ? '4' : '5013332982')
        : '',
  );
  final form = GlobalKey<FormState>();

  @override
  void dispose() {
    value.dispose();
    super.dispose();
  }

  void submit() {
    if (!form.currentState!.validate()) return;
    final state = context.state;
    FocusScope.of(context).unfocus();
    if (widget.verify) {
      state.signIn(state.pendingPhone);
      context.reset(Screen.address);
    } else {
      state.pendingPhone = '+1 ${value.text.trim()}';
      context.open(Screen.verify);
    }
  }

  @override
  Widget build(BuildContext context) {
    final verify = widget.verify;
    return PageFrame(
      header: const ScreenHeader('Login to Foodor'),
      body: Form(
        key: form,
        child: ContentList([
          space(3),
          IntroText(
            verify ? 'Verify Phone Number' : 'Get Started\nwith Foodor',
            verify
                ? 'Enter the 4-digit demo code 4444 for ${context.state.pendingPhone}.'
                : 'Enter your phone number below to confirm your account.',
          ),
          space(22),
          if (verify)
            codeEntry()
          else
            Field(
              '(501) 333-2982',
              value,
              highlight: widget.active || value.text.isNotEmpty,
              autofocus: true,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
              prefix: Padding(
                padding: const EdgeInsets.fromLTRB(15, 14, 9, 0),
                child: Text('🇺🇸  +1', style: type(15, color: coral)),
              ),
              validator: validPhone,
              onSubmitted: (_) => submit(),
            ),
          space(22),
          ActionButton(verify ? 'CONTINUE' : 'NEXT', submit),
          if (verify) ...[
            space(16),
            Center(
              child: MiniAction(
                'Didn’t receive code? Resend Again.',
                () => context.showMessage('Your demo code is 4444.'),
                background: false,
              ),
            ),
          ],
        ]),
      ),
    );
  }

  Widget codeEntry() {
    final code = value.text;
    return Stack(
      children: [
        Semantics(
          label: '4-digit code',
          child: TextFormField(
            controller: value,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.done,
            maxLength: 4,
            showCursor: false,
            style: const TextStyle(color: Colors.transparent, height: 1.6),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
            validator: (value) =>
                value == '4444' ? null : 'Enter the demo code 4444',
            onChanged: (_) => setState(() {}),
            onFieldSubmitted: (_) => submit(),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var index = 0; index < 4; index++)
                  Container(
                    width: 48,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: index == code.length
                              ? red
                              : const Color(0xffffbaae),
                        ),
                      ),
                    ),
                    child: Text(
                      index < code.length ? code[index] : '',
                      style: type(21, color: coral, weight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AddressPage extends StatefulWidget {
  const AddressPage(this.screen, {super.key});
  final Screen screen;

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final query = TextEditingController();

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  void pick(String city, {Screen next = Screen.home}) {
    if (city.trim().isEmpty) return;
    context.state.setLocation(city.trim());
    if (widget.screen == Screen.locations) {
      context.close();
    } else {
      context.reset(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.state;
    final isEntry = widget.screen == Screen.addressEntry;
    final isSaved = widget.screen == Screen.locations;
    final value = query.text.trim();
    final matches = state.recentAddresses
        .where((city) => city.toLowerCase().contains(value.toLowerCase()))
        .toList();
    return PageFrame(
      header: ScreenHeader(
        isSaved ? 'Locations' : '',
        dismiss: !isSaved,
        onBack: isSaved
            ? null
            : () {
                if (Navigator.of(context).canPop()) {
                  context.close();
                } else {
                  context.reset(Screen.home);
                }
              },
      ),
      body: ContentList([
        if (!isSaved) ...[
          space(10),
          const IntroText(
            'Find restaurants near you',
            'Please enter your location or choose the demo location to find restaurants near you.',
          ),
          space(23),
        ],
        if (!isEntry && !isSaved) ...[
          ActionButton(
            'Use current location',
            () => pick(cities.first),
            icon: Icons.near_me,
          ),
          space(18),
          TintRow(
            'Enter a new address',
            icon: Icons.location_on,
            onTap: () => context.open(Screen.addressEntry),
          ),
          Center(
            child: MiniAction(
              'Find restaurants on the map',
              () => pick(state.location, next: Screen.nearby),
              background: false,
            ),
          ),
        ] else ...[
          Field(
            'Enter a new address',
            query,
            highlight: true,
            icon: Icons.location_on,
            autofocus: isEntry,
            action: TextInputAction.search,
            onChanged: (_) => setState(() {}),
            onSubmitted: pick,
          ),
          space(16),
          if (isSaved)
            SectionTitle(
              'RECENT ADDRESS',
              size: 14,
              action: 'CLEAR ALL',
              onTap: () {
                state.recentAddresses.clear();
                state.changed();
              },
            ),
          if (value.isNotEmpty && matches.isEmpty)
            TintRow(
              value,
              subtitle: 'Use entered address',
              icon: Icons.location_on,
              onTap: () => pick(value),
            ),
          for (final city in matches)
            TintRow(
              city,
              subtitle: city == cities.first || city == cities[1]
                  ? 'California'
                  : 'United States',
              icon: Icons.near_me,
              onTap: () => pick(city),
            ),
        ],
      ]),
    );
  }
}
