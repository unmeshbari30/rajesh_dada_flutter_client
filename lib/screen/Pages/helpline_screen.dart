import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rajesh_dada_padvi/controllers/home_controller.dart';
import 'package:rajesh_dada_padvi/l10n/app_localizations.dart';
import 'package:rajesh_dada_padvi/models/emergency_contact_model.dart';
import 'package:rajesh_dada_padvi/widgets/app_page_frame.dart';
import 'package:url_launcher/url_launcher.dart';

class HelplineScreen extends ConsumerWidget {
  const HelplineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeStateAsync = ref.watch(homeControllerProvider);

    return homeStateAsync.when(
      data: (state) => _HelplineBody(
        contactsFuture: state.emergencyContactsResponse,
        onRefresh: () async {
          ref.invalidate(homeControllerProvider);
          await ref.read(homeControllerProvider.future);
        },
      ),
      error: (_, __) => _HelplineFrame(
        child: _ErrorView(
          message: 'Failed to load data.\nPull down to retry.',
          onRefresh: () async {
            ref.invalidate(homeControllerProvider);
            await ref.read(homeControllerProvider.future);
          },
        ),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _HelplineBody extends StatelessWidget {
  final Future<List<EmergencyContactModel>?>? contactsFuture;
  final Future<void> Function() onRefresh;

  const _HelplineBody({required this.contactsFuture, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return _HelplineFrame(
      child: FutureBuilder<List<EmergencyContactModel>?>(
        future: contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorView(
              message: 'Failed to load contacts.\nPull down to retry.',
              onRefresh: onRefresh,
            );
          }

          final contacts = snapshot.data;
          if (contacts == null || contacts.isEmpty) {
            return _ErrorView(
              message: 'No contacts available.\nPull down to refresh.',
              onRefresh: onRefresh,
            );
          }

          return _ContactList(contacts: contacts, onRefresh: onRefresh);
        },
      ),
    );
  }
}

class _HelplineFrame extends StatelessWidget {
  final Widget child;

  const _HelplineFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return AppPageFrame(
      title: context.l10n.helplineTitle,
      subtitle: context.l10n.helplineSubtitle,
      icon: Icons.support_agent_rounded,
      child: child,
    );
  }
}

class _ContactList extends StatelessWidget {
  final List<EmergencyContactModel> contacts;
  final Future<void> Function() onRefresh;

  const _ContactList({required this.contacts, required this.onRefresh});

  IconData _iconForType(String? type) {
    switch (type) {
      case 'emergency':
        return Icons.emergency_rounded;
      case 'police':
        return Icons.local_police_rounded;
      case 'fire':
        return Icons.fire_truck_rounded;
      case 'ambulance':
        return Icons.local_hospital_rounded;
      case 'tehsil':
        return Icons.apartment_rounded;
      default:
        return Icons.phone_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    _iconForType(contact.icon),
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(contact.number ?? ''),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.call_rounded),
                  onPressed: () async {
                    final Uri uri = Uri(scheme: 'tel', path: contact.number);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRefresh;

  const _ErrorView({required this.message, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: Center(
              child: Text(message, textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }
}
