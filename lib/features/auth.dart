import 'dart:async';

import 'package:flutter/material.dart';

import '../core/session.dart';
import '../core/ui.dart';
import '../data/design.dart';

class AuthFlow extends StatefulWidget {
  const AuthFlow(this.session, {super.key});

  final Session session;

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  final _first = TextEditingController();
  final _second = TextEditingController();
  final _third = TextEditingController();
  Timer? _splashTimer;
  String _code = '';

  Session get session => widget.session;
  Screen get screen => session.screen;
  bool get preview => session.preview;
  bool get signUp => screen == Screen.signUp || screen == Screen.signUpActive;

  @override
  void initState() {
    super.initState();
    switch (screen) {
      case Screen.splash:
        if (!preview) {
          _splashTimer = Timer(const Duration(milliseconds: 1200), () {
            if (mounted) session.open(Screen.onboardingOne, replace: true);
          });
        }
      case Screen.loginActive || Screen.resetEmail:
        _first.text = 'bebyjovanca@gmail.c';
      case Screen.signUpActive:
        _first.text = 'Azalea';
      case Screen.resetPhone:
        if (preview) _first.text = '+62823328779';
      case Screen.newPassword:
        if (preview) _first.text = 'lezatos123';
      case Screen.verifyEmail:
        if (preview) _code = '51';
      case Screen.verifyPhone:
        if (preview) _code = '5';
      default:
        break;
    }
    if (screen == Screen.resetEmail && !preview) _first.clear();
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _first.dispose();
    _second.dispose();
    _third.dispose();
    super.dispose();
  }

  void _signIn() => session.open(session.home, reset: true);

  bool _emailValid(String value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());

  void _submitAccount() {
    final email = signUp ? _second.text : _first.text;
    final password = signUp ? _third.text : _second.text;
    if (signUp && _first.text.trim().isEmpty) {
      notice(context, 'Enter a username');
      return;
    }
    if (!_emailValid(email) || password.length < 6) {
      notice(context, 'Enter a valid email and at least 6 password characters');
      return;
    }
    session.email = email.trim();
    if (signUp) {
      session.name = _first.text.trim();
      session.signingUp = true;
      session.open(Screen.verifyEmail);
      notice(context, 'Demo verification code is 5123');
    } else {
      _signIn();
    }
  }

  @override
  Widget build(BuildContext context) => switch (screen) {
    Screen.splash => Center(
      child: InkWell(
        onTap: () => session.open(Screen.onboardingOne, replace: true),
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: art(
            'splash_brand',
            width: 208,
            height: 56,
            fit: BoxFit.contain,
          ),
        ),
      ),
    ),
    Screen.onboardingOne ||
    Screen.onboardingTwo ||
    Screen.onboardingThree => _onboarding(),
    Screen.login ||
    Screen.loginActive ||
    Screen.signUp ||
    Screen.signUpActive => _account(),
    Screen.forgot => _forgot(),
    Screen.resetEmail || Screen.resetPhone => _reset(),
    Screen.verifyEmail || Screen.verifyPhone => _verification(),
    Screen.newPassword => _newPassword(),
    Screen.passwordChanged => _success(),
    _ => const SizedBox.shrink(),
  };

  Widget _onboarding() {
    final step = screen.index - Screen.onboardingOne.index;
    final next = [
      Screen.onboardingTwo,
      Screen.onboardingThree,
      Screen.login,
    ][step];
    return LayoutBuilder(
      builder: (context, constraints) {
        final heroHeight = (constraints.maxHeight * .58).clamp(250.0, 460.0);
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            art(
              'onboarding_${step + 1}',
              width: double.infinity,
              height: heroHeight,
              fit: BoxFit.fill,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  label(
                    '312+ Foods',
                    size: 16,
                    color: muted,
                    weight: FontWeight.w400,
                  ),
                  const SizedBox(height: 12),
                  heading('Delicious Variant and Fast Delivery', size: 32),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CircleAvatar(
                            radius: 6,
                            backgroundColor: i == step ? orange : line,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      link(
                        'Skip',
                        () => session.open(Screen.login, reset: true),
                        color: muted,
                      ),
                      SizedBox(
                        width: 106,
                        child: action(
                          'Next',
                          () => session.open(next, replace: true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _account() {
    final title = signUp ? 'Sign Up' : 'Sign In';
    return verticalBody([
      const SizedBox(height: 45),
      heading(signUp ? 'Sign Up' : 'Hi! Welcome back', size: 32),
      const SizedBox(height: 8),
      label(
        signUp ? 'Please fill out the form below!' : 'Sign In to your account',
        size: 16,
        color: muted,
        weight: FontWeight.w400,
      ),
      const SizedBox(height: 24),
      if (signUp) ...[
        FormFieldPill(
          controller: _first,
          hint: 'Username',
          icon: Icons.person_outline,
          highlighted: screen == Screen.signUpActive,
        ),
        const SizedBox(height: 16),
      ],
      FormFieldPill(
        controller: signUp ? _second : _first,
        hint: 'Type your email',
        icon: Icons.mail_outline_rounded,
        type: TextInputType.emailAddress,
        highlighted: screen == Screen.loginActive,
      ),
      const SizedBox(height: 16),
      FormFieldPill(
        controller: signUp ? _third : _second,
        hint: 'Type your password',
        icon: Icons.lock_outline_rounded,
        secret: true,
        action: TextInputAction.done,
        onSubmit: (_) => _submitAccount(),
      ),
      if (!signUp)
        Align(
          alignment: Alignment.centerRight,
          child: link('Forgot Password?', () => session.open(Screen.forgot)),
        )
      else
        const SizedBox(height: 16),
      action(title, _submitAccount),
      const SizedBox(height: 26),
      Row(
        children: [
          const Expanded(child: Divider(color: line)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: label(
              signUp ? 'Or sign up with' : 'Or sign in with',
              color: muted,
              weight: FontWeight.w400,
            ),
          ),
          const Expanded(child: Divider(color: line)),
        ],
      ),
      const SizedBox(height: 22),
      _provider(title, 'Apple', const Icon(Icons.apple, color: ink)),
      const SizedBox(height: 16),
      _provider(
        title,
        'Google',
        art('google', width: 22, height: 22, fit: BoxFit.contain),
      ),
      const SizedBox(height: 16),
      Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          label(
            signUp ? 'Have an account?' : 'Don’t have an account?',
            weight: FontWeight.w400,
          ),
          link(
            signUp ? 'Sign In' : 'Sign Up',
            () => session.open(
              signUp ? Screen.login : Screen.signUp,
              replace: true,
            ),
          ),
        ],
      ),
      const SizedBox(height: 48),
      Center(
        child: label(
          'By using our services you are agreeing to our',
          weight: FontWeight.w400,
          align: TextAlign.center,
        ),
      ),
      Center(
        child: link(
          'Terms and Privacy Policy',
          () => info(
            context,
            'Terms and Privacy Policy',
            'This local demo uses example account data. Sign-in and verification run on this device.',
          ),
        ),
      ),
    ]);
  }

  Widget _provider(String title, String provider, Widget mark) => SizedBox(
    width: double.infinity,
    height: 56,
    child: OutlinedButton(
      onPressed: () => info(
        context,
        provider,
        'Use email and a demo password to explore the local app.',
      ),
      style: OutlinedButton.styleFrom(side: const BorderSide(color: line)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          mark,
          const SizedBox(width: 16),
          label('$title with $provider', weight: FontWeight.w700),
        ],
      ),
    ),
  );

  Widget _authIntro(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      heading(title, size: 32),
      const SizedBox(height: 9),
      label(
        subtitle,
        size: 15,
        color: muted,
        weight: FontWeight.w400,
        maxLines: 3,
      ),
      const SizedBox(height: 24),
    ],
  );

  Widget _authPage(List<Widget> body, {Widget? bottom}) => Column(
    children: [
      toolbar('', session.back),
      Expanded(child: verticalBody([const SizedBox(height: 24), ...body])),
      if (bottom != null) footer(bottom),
    ],
  );

  Widget _forgot() => _authPage([
    _authIntro(
      'Forgot Password',
      'Select which contact details we should use to reset your password',
    ),
    _method(
      'Email',
      '********@mail.com',
      Icons.mail_outline,
      Screen.resetEmail,
    ),
    const SizedBox(height: 16),
    _method(
      'Phone Number',
      '**** **** **** 2345',
      Icons.call_outlined,
      Screen.resetPhone,
    ),
  ]);

  Widget _method(
    String title,
    String hint,
    IconData icon,
    Screen destination,
  ) => InkWell(
    onTap: () => session.open(destination),
    borderRadius: BorderRadius.circular(32),
    child: panel(
      border: line,
      radius: 32,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xffffefe7),
            child: Icon(icon, color: orange, size: 19),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading(title, size: 14),
              label(hint, color: muted, weight: FontWeight.w400),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _reset() {
    final phone = screen == Screen.resetPhone;
    void send() {
      final value = _first.text.trim();
      final valid = phone
          ? RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value)
          : _emailValid(value);
      if (!valid) {
        notice(
          context,
          phone ? 'Enter a valid phone number' : 'Enter a valid email address',
        );
        return;
      }
      session.signingUp = false;

      session.open(phone ? Screen.verifyPhone : Screen.verifyEmail);
      notice(context, 'Demo verification code is 5123');
    }

    return _authPage([
      _authIntro(
        'Reset Password',
        phone
            ? 'Enter your phone number, we will send a verification code to your number'
            : 'Enter your email, we will send a verification code to your email',
      ),
      FormFieldPill(
        controller: _first,
        hint: phone ? 'Phone number' : 'Email',
        icon: phone ? Icons.flag_rounded : Icons.mail_outline,
        type: phone ? TextInputType.phone : TextInputType.emailAddress,
        action: TextInputAction.done,
        onSubmit: (_) => send(),
        highlighted: preview,
      ),
    ], bottom: action('Send Link', send));
  }

  Widget _verification() {
    final phone = screen == Screen.verifyPhone;
    void verify() {
      if (_code != '5123') {
        notice(context, 'Enter the demo code 5123');
        return;
      }
      if (session.signingUp) {
        _signIn();
      } else {
        session.open(Screen.newPassword);
      }
    }

    return verticalBody([
      if (phone) toolbar('', session.back),
      SizedBox(height: phone ? 24 : 45),
      _authIntro(
        'Verification Code',
        phone
            ? 'Enter the verification code that we have sent to your phone number'
            : 'Please enter the verification code that we have sent to your email',
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < 4; i++)
            panel(
              radius: 30,
              border: i == _code.length ? orange : line,
              child: SizedBox(
                width: 54,
                height: 54,
                child: Center(
                  child: heading(i < _code.length ? _code[i] : ' ', size: 24),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 12),
      Center(
        child: link('Resend Code', () {
          setState(() => _code = '');
          notice(context, 'Demo verification code is 5123');
        }),
      ),
      const SizedBox(height: 68),
      action('Continue', verify),
      const SizedBox(height: 4),
      for (final row in const [
        ['1', '2', '3'],
        ['4', '5', '6'],
        ['7', '8', '9'],
        ['.', '0', 'Delete'],
      ])
        Row(
          children: [
            for (final key in row)
              Expanded(
                child: SizedBox(
                  height: 76,
                  child: TextButton(
                    onPressed: () => setState(() {
                      if (key == 'Delete' && _code.isNotEmpty) {
                        _code = _code.substring(0, _code.length - 1);
                      } else if (key != '.' &&
                          key != 'Delete' &&
                          _code.length < 4) {
                        _code += key;
                      }
                    }),
                    child: key == 'Delete'
                        ? const Icon(Icons.backspace_outlined, color: ink)
                        : heading(key, size: 28),
                  ),
                ),
              ),
          ],
        ),
    ]);
  }

  Widget _newPassword() => _authPage(
    [
      _authIntro(
        'Create New Password',
        'Your password must be different from previous used password',
      ),
      FormFieldPill(
        controller: _first,
        hint: 'New password',
        icon: Icons.lock_outline,
        secret: true,
        highlighted: preview,
      ),
      const SizedBox(height: 16),
      FormFieldPill(
        controller: _second,
        hint: 'Confirm your password',
        icon: Icons.lock_outline,
        secret: true,
        action: TextInputAction.done,
      ),
    ],
    bottom: action('Reset Password', () {
      if (_first.text.length < 6 || _first.text != _second.text) {
        notice(context, 'Enter matching passwords of at least 6 characters');
        return;
      }
      session.open(Screen.passwordChanged);
    }),
  );

  Widget _success() => Column(
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: iconAction(
          Icons.close,
          'Close',
          () => session.open(Screen.login, reset: true),
        ),
      ),
      Expanded(
        child: Center(
          child: SingleChildScrollView(
            padding: gutter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                art(
                  'password_success',
                  width: 230,
                  height: 230,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 22),
                heading('Password Changed', size: 32, align: TextAlign.center),
                const SizedBox(height: 8),
                label(
                  'Password changed successfully. You can log in again with your new password.',
                  color: muted,
                  align: TextAlign.center,
                  size: 16,
                  weight: FontWeight.w400,
                ),
              ],
            ),
          ),
        ),
      ),
      footer(
        action('Sign In Now', () => session.open(Screen.login, reset: true)),
      ),
    ],
  );
}
