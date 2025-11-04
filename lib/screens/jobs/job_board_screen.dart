import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findom/models/job_model.dart';
import 'package:findom/models/company_model.dart';
import 'package:findom/screens/jobs/job_detail_screen.dart';

class JobBoardScreen extends StatelessWidget {
  const JobBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Board'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('jobs').orderBy('postedDate', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No job listings available right now."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final job = Job.fromFirestore(snapshot.data!.docs[index]);
              return JobCard(job: job);
            },
          );
        },
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final Job job;

  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('companies').doc(job.companyId).get(),
      builder: (context, companySnapshot) {
        if (companySnapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(title: Text('Loading...'));
        }
        if (!companySnapshot.hasData) {
          return const ListTile(title: Text('Could not load company'));
        }

        final company = Company.fromFirestore(companySnapshot.data!);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            leading: company.logoUrl != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(company.logoUrl!),
                    backgroundColor: Colors.grey[200],
                  )
                : const CircleAvatar(child: Icon(Icons.business)),
            title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${company.name} • ${job.location}'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => JobDetailScreen(job: job),
              ));
            },
          ),
        );
      },
    );
  }
}
