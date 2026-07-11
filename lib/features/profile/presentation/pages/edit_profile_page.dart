import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/profile_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});
  @override ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).valueOrNull;
    if (profile != null) {
      _nameCtrl.text = profile.name;
      _emailCtrl.text = profile.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(profileUpdateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          AppTextField(label: 'Full Name', controller: _nameCtrl),
          const SizedBox(height: 16),
          AppTextField(label: 'Email', controller: _emailCtrl),
          const Spacer(),
          AppButton.primary(
            label: 'Save Changes',
            isLoading: updateState is AsyncLoading,
            onPressed: () async {
              final ok = await ref.read(profileUpdateProvider.notifier).update({'name': _nameCtrl.text, 'email': _emailCtrl.text});
              if (ok && mounted) Navigator.of(context).pop();
            },
          ),
        ]),
      ),
    );
  }
}
