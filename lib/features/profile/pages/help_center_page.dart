import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';

class FaqItem {
  final String question;
  final String answer;

  const FaqItem({required this.question, required this.answer});
}

class ContactChannel {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ContactChannel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);

  final List<FaqItem> _faqs = const [
    FaqItem(
      question: 'What services can I book through lekhan_ai?',
      answer:
          'You can book a wide range of home and personal services, including plumbing, electrical work, cleaning, carpentry, AC repair, appliance repair, painting, pest control, gardening, mechanics, beauty services, tutoring, moving, and more.',
    ),
    FaqItem(
      question: 'How do I book a service?',
      answer:
          'Choose a category from the home screen, describe your issue with photos or a video, pick a date and address, and select a pro from the list of available workers.',
    ),
    FaqItem(
      question: 'How do I know if a professional is trustworthy?',
      answer:
          'Every listed pro goes through government ID verification and a background check, and displays a rating built from real customer reviews.',
    ),
    FaqItem(
      question: 'How much does a service cost?',
      answer:
          'Pricing varies by service type, urgency, and the professional you choose. You will always see the rate or your accepted budget before confirming a booking.',
    ),
    FaqItem(
      question: 'Can I cancel or reschedule my booking?',
      answer:
          'Yes — open the booking from My Bookings and use the Reschedule option, or cancel from there before the pro starts the job.',
    ),
    FaqItem(
      question: 'What if I am not satisfied with the service?',
      answer:
          'Reach out through Help Center > Contact us within 24 hours of job completion and our support team will help resolve it, including re-service or a refund where applicable.',
    ),
  ];

  final List<bool> _expanded = [];

  @override
  void initState() {
    super.initState();
    _expanded.addAll(List.generate(_faqs.length, (index) => index == 0));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleFaq(int index) {
    setState(() => _expanded[index] = !_expanded[index]);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.onSurface, size: 18),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'Help Center',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: TabBar(
            controller: _tabController,
            labelColor: colorScheme.secondary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            labelStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            unselectedLabelStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            indicatorColor: colorScheme.secondary,
            indicatorWeight: 2.5,
            tabs: const [
              Tab(text: 'FAQ'),
              Tab(text: 'Contact us'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FaqTab(
            faqs: _faqs,
            expanded: _expanded,
            colorScheme: colorScheme,
            textTheme: textTheme,
            onToggle: _toggleFaq,
          ),
          _ContactUsTab(
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}

// ============= FAQ TAB =============

class _FaqTab extends StatelessWidget {
  final List<FaqItem> faqs;
  final List<bool> expanded;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final ValueChanged<int> onToggle;

  const _FaqTab({
    required this.faqs,
    required this.expanded,
    required this.colorScheme,
    required this.textTheme,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: faqs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _FaqCard(
          item: faqs[index],
          isExpanded: expanded[index],
          colorScheme: colorScheme,
          textTheme: textTheme,
          onTap: () => onToggle(index),
        );
      },
    );
  }
}

class _FaqCard extends StatelessWidget {
  final FaqItem item;
  final bool isExpanded;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;

  const _FaqCard({
    required this.item,
    required this.isExpanded,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.question,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                item.answer,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}

// ============= CONTACT US TAB =============

class _ContactUsTab extends StatelessWidget {
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _ContactUsTab({required this.colorScheme, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    final channels = [
      ContactChannel(
        icon: Iconsax.call,
        title: 'Call Support',
        subtitle: '+977 1-4XXXXXX · 9 AM – 8 PM, daily',
        onTap: () {
          // Placeholder — launch phone dialer via url_launcher:
          // launchUrl(Uri(scheme: 'tel', path: '+97714XXXXXX'));
        },
      ),
      ContactChannel(
        icon: Iconsax.sms,
        title: 'Email Us',
        subtitle: 'support@lekhan_ai.com',
        onTap: () {
          // Placeholder — launch email client via url_launcher:
          // launchUrl(Uri(scheme: 'mailto', path: 'support@lekhan_ai.com'));
        },
      ),
      ContactChannel(
        icon: Iconsax.message_question,
        title: 'Live Chat',
        subtitle: 'Chat with our support team in-app',
        onTap: () {
          // Placeholder for future navigation to in-app chat support
          // context.push('support-chat');
        },
      ),
      ContactChannel(
        icon: Iconsax.message,
        title: 'WhatsApp',
        subtitle: 'Message us for quick help',
        onTap: () {
          // Placeholder — launch WhatsApp via url_launcher:
          // launchUrl(Uri.parse('https://wa.me/97714XXXXXX'));
        },
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: [
        Text(
          'Get in touch',
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "We're here to help with bookings, payments, or anything else.",
          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        ...channels.map((channel) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ContactChannelTile(
              channel: channel,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          );
        }),
      ],
    );
  }
}

class _ContactChannelTile extends StatelessWidget {
  final ContactChannel channel;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _ContactChannelTile({
    required this.channel,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: channel.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(channel.icon, size: 20, color: colorScheme.secondary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel.title,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    channel.subtitle,
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
           Icon(Icons.chevron_right, size: 20, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}