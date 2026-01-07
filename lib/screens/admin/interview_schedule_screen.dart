import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../config/theme.dart';

class InterviewScheduleScreen extends StatefulWidget {
  const InterviewScheduleScreen({super.key});

  @override
  State<InterviewScheduleScreen> createState() => _InterviewScheduleScreenState();
}

class _InterviewScheduleScreenState extends State<InterviewScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadInterviews();
      context.read<AppProvider>().loadApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Interview'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<AppProvider>().loadInterviews();
          await context.read<AppProvider>().loadApplications();
        },
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            final interviews = provider.interviews;
            
            // Group by date
            final groupedInterviews = <String, List<dynamic>>{};
            for (final interview in interviews) {
              final dateKey = DateFormat('yyyy-MM-dd').format(interview.scheduledAt);
              groupedInterviews.putIfAbsent(dateKey, () => []);
              groupedInterviews[dateKey]!.add(interview);
            }

            // Sort dates
            final sortedDates = groupedInterviews.keys.toList()
              ..sort((a, b) => a.compareTo(b));

            if (interviews.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada jadwal interview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.subtitleColor,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Jadwalkan interview dari detail pelamar',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedDates.length,
              itemBuilder: (context, dateIndex) {
                final dateKey = sortedDates[dateIndex];
                final dayInterviews = groupedInterviews[dateKey]!;
                final date = DateTime.parse(dateKey);
                final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateKey;
                final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isToday
                                  ? AppTheme.primaryColor
                                  : isPast
                                      ? Colors.grey.shade400
                                      : AppTheme.secondaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isToday
                                  ? 'Hari Ini'
                                  : DateFormat('EEEE, dd MMM').format(date),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${dayInterviews.length} interview',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    ...dayInterviews.map((interview) {
                      // Find application
                      final app = provider.applications.firstWhere(
                        (a) => a.id == interview.applicationId,
                        orElse: () => provider.applications.first,
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                            child: Text(
                              app.fullName.isNotEmpty ? app.fullName[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(app.fullName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('HH:mm').format(interview.scheduledAt) + ' WIB',
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                interview.location,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: interview.isConfirmed
                              ? Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.acceptedColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: AppTheme.acceptedColor,
                                    size: 16,
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.warningColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.schedule,
                                    color: AppTheme.warningColor,
                                    size: 16,
                                  ),
                                ),
                          isThreeLine: true,
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
