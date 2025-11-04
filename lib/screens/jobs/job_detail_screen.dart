import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findom/models/job_model.dart';
import 'package:findom/models/company_model.dart';

class JobDetailScreen extends StatelessWidget {
  final Job job;

  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(job.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompanyHeader(),
            const SizedBox(height: 24),
            _buildJobInfo(),
            const Divider(height: 32),
            Text('Job Description', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(job.description),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(onPressed: () {}, child: const Text('Apply Now')),
      ),
    );
  }

  Widget _buildCompanyHeader() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('companies').doc(job.companyId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final company = Company.fromFirestore(snapshot.data!);

        return Row(
          children: [
            company.logoUrl != null
                ? CircleAvatar(radius: 30, backgroundImage: NetworkImage(company.logoUrl!))
                : const CircleAvatar(radius: 30, child: Icon(Icons.business)),
            const SizedBox(width: 16),
            Text(company.name, style: Theme.of(context).textTheme.titleLarge),
          ],
        );
      },
    );
  }

  Widget _buildJobInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(Icons.location_on, job.location),
        const SizedBox(height: 8),
        _infoRow(Icons.work, job.employmentType.toString().split('.').last),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
