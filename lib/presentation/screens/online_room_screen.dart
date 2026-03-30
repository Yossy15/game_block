import 'package:block/domain/models/online_room.dart';
import 'package:block/presentation/view_models/online_room_form_state.dart';
import 'package:block/presentation/view_models/online_room_form_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

class OnlineRoomScreen extends ConsumerStatefulWidget {
  const OnlineRoomScreen({super.key});

  @override
  ConsumerState<OnlineRoomScreen> createState() => _OnlineRoomScreenState();
}

class _OnlineRoomScreenState extends ConsumerState<OnlineRoomScreen> {
  final _nameController = TextEditingController();
  final _roomCodeController = TextEditingController();
  final _durationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController.text = 'Player';
    _durationController.text = '5';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomCodeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(onlineRoomFormViewModelProvider);
    final viewModel = ref.read(onlineRoomFormViewModelProvider.notifier);

    if (_durationController.text != formState.durationMinutes) {
      _durationController.value = _durationController.value.copyWith(
        text: formState.durationMinutes,
        selection: TextSelection.collapsed(offset: formState.durationMinutes.length),
      );
    }

    ref.listen<OnlineRoomFormState>(onlineRoomFormViewModelProvider, (
      previous,
      next,
    ) {
      final previousSession = previous?.session;
      final nextSession = next.session;

      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        // ScaffoldMessenger.of(context)
        //   ..hideCurrentSnackBar()
        //   ..showSnackBar(SnackBar(content: Text(next.errorMessage!)));
        toastification.show(
          context: context, // optional if you use ToastificationWrapper
          title: Text(next.errorMessage!),
          style: ToastificationStyle.flatColored,
          primaryColor: Colors.redAccent,
          autoCloseDuration: const Duration(seconds: 3),
          closeOnClick: false,
          icon: const Icon(Icons.error_outline, color: Colors.redAccent),
        );
      }

      if (nextSession != null && nextSession != previousSession) {
        _openGame(context, nextSession);
        viewModel.clearSession();
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF060112),
              Color(0xFF120324),
              Color(0xFF1D0933),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        ),
                      ),
                      const Gap(12),
                      Text(
                        'BATTER ONLINE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          shadows: [
                            Shadow(
                              color: const Color(0xFFFF6B2F).withValues(alpha: 0.45),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      const Gap(10),
                      Text(
                        'Create a room with custom time or unlimited mode, or enter a 6-character code to join.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                      const Gap(28),
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _FieldLabel('PLAYER NAME'),
                            const Gap(10),
                            TextFormField(
                              controller: _nameController,
                              style: GoogleFonts.itim(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              // TextStyle(color: Colors.white, fontFamily: 'Itim'),
                              decoration: _inputDecoration('Your display name'),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter your name';
                                }
                                return null;
                              },
                            ),
                            const Gap(20),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _FieldLabel('MATCH TIME'),
                                  const Gap(8),
                                  SwitchListTile.adaptive(
                                    contentPadding: EdgeInsets.zero,
                                    value: formState.isUnlimitedTime,
                                    onChanged: viewModel.setUnlimitedTime,
                                    activeThumbColor: const Color(0xFFFF6B2F),
                                    activeTrackColor: const Color(0xFFFF6B2F).withValues(
                                      alpha: 0.35,
                                    ),
                                    title: const Text(
                                      'Unlimited time',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      'Turn off to set a custom minute limit.',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.55),
                                      ),
                                    ),
                                  ),
                                  if (!formState.isUnlimitedTime) ...[
                                    const Gap(10),
                                    TextFormField(
                                      controller: _durationController,
                                      keyboardType: TextInputType.number,
                                      style: GoogleFonts.itim(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: _inputDecoration('Minutes').copyWith(
                                        suffixText: 'min',
                                        suffixStyle: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.55),
                                        ),
                                      ),
                                      onChanged: viewModel.setDurationMinutes,
                                      validator: (value) {
                                        if (formState.isUnlimitedTime) {
                                          return null;
                                        }

                                        final minutes = int.tryParse((value ?? '').trim());
                                        if (minutes == null || minutes <= 0) {
                                          return 'Enter minutes greater than 0';
                                        }

                                        return null;
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Gap(20),
                            FilledButton(
                              onPressed: () async {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }
                                      final durationSeconds = formState.isUnlimitedTime
                                          ? null
                                          : (int.tryParse(formState.durationMinutes.trim()) ?? 5) *
                                              60;
                                      await viewModel.createRoom(
                                        playerName: _nameController.text.trim(),
                                        durationSeconds: durationSeconds,
                                      );
                                      toastification.show(
                                        context: context, // optional if you use ToastificationWrapper
                                        title: Text('Room created successfully!'),
                                        style: ToastificationStyle.flatColored,
                                        autoCloseDuration: const Duration(seconds: 3),
                                        icon: const Icon(Icons.check_circle_outline, color: Colors.greenAccent),
                                      );
                                    },
                              style: formState.isLoading
                                  ? _buttonStyle(
                                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                                    )
                                  : _buttonStyle(
                                      backgroundColor: const Color(0xFFFF6B2F),
                                    ),
                              child: formState.isLoading
                                  ? const _ButtonBusyLabel(label: 'CREATING ROOM')
                                  : const Text('CREATE ROOM'),
                            ),
                          ],
                        ),
                      ),
                      const Gap(18),
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _FieldLabel('ROOM CODE'),
                            const Gap(10),
                            TextFormField(
                              controller: _roomCodeController,
                              textCapitalization: TextCapitalization.characters,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              style: GoogleFonts.itim(
                                color: Colors.white,
                                fontSize: 16,
                                letterSpacing: 6,
                                fontWeight: FontWeight.w700,
                              ),
                              // const TextStyle(
                              //   color: Colors.white,
                              //   letterSpacing: 6,
                              //   fontWeight: FontWeight.w700,
                              // ),
                              decoration: _inputDecoration('000000').copyWith(
                                counterText: '',
                              ),
                            ),
                            const Gap(16),
                            OutlinedButton(
                              onPressed: formState.isLoading
                                  ? null
                                  : () async {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }

                                      final roomCode =
                                          _roomCodeController.text.trim().toUpperCase();
                                      if (roomCode.length != 6) {
                                        // ScaffoldMessenger.of(context)
                                        //   ..hideCurrentSnackBar()
                                        //   ..showSnackBar(
                                        //     const SnackBar(
                                        //       content: Text('Room code must be 6 characters'),
                                        //     ),
                                        //   );
                                          toastification.show(
                                            context: context, // optional if you use ToastificationWrapper
                                            title: const Text('Room code must be 6 characters'),
                                            style: ToastificationStyle.flatColored,
                                            primaryColor: Colors.redAccent,
                                            autoCloseDuration: const Duration(seconds: 3),
                                            closeOnClick: false,
                                            icon: const Icon(Icons.error_outline, color: Colors.redAccent),
                                          );
                                        return;
                                      }

                                      await viewModel.joinRoom(
                                        roomCode: roomCode,
                                        playerName: _nameController.text.trim(),
                                      );
                                    },
                              style: formState.isLoading
                                  ? _buttonStyle(
                                backgroundColor: Colors.transparent,
                                side: const BorderSide(color: Color(0xFFFF6B2F), width: 1.3),
                              )
                                  : _buttonStyle(
                                backgroundColor: Colors.transparent,
                                side: const BorderSide(color: Color(0xFFFF6B2F), width: 1.3),
                              ),
                              child: formState.isLoading
                                  ? const _ButtonBusyLabel(label: 'JOINING ROOM')
                                  : const Text('JOIN WITH CODE'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openGame(BuildContext context, OnlineRoomSession session) {
    context.goNamed(
      'online-lobby',
      queryParameters: {
        'roomCode': session.roomCode,
        'playerId': session.playerId,
      },
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.28)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFFFF6B2F), width: 1.4),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Colors.redAccent),
      ),
    );
  }

  ButtonStyle _buttonStyle({
    required Color backgroundColor,
    BorderSide? side,
  }) {
    return FilledButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      side: side,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.6),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.4,
      ),
    );
  }
}

class _ButtonBusyLabel extends StatelessWidget {
  const _ButtonBusyLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // const SizedBox(
        //   width: 16,
        //   height: 16,
        //   child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        // ),
        // const Gap(10),
        Text(label),
      ],
    );
  }
}
