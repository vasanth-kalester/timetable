import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/config/theme/app_colors.dart';

class DigitalIdCardWidget extends StatelessWidget {
  final UserEntity user;

  const DigitalIdCardWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.indigoAccent.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Campus Branding & Role Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.indigoAccent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.school_rounded, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'EDUFLOW CAMPUS OS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRoleColor(user.role).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getRoleColor(user.role)),
                ),
                child: Text(
                  user.role.name.toUpperCase(),
                  style: TextStyle(
                    color: _getRoleColor(user.role),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // User Info & QR Code
          Row(
            children: [
              // User Avatar
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.indigo.shade300,
                child: Text(
                  user.fullName.isNotEmpty ? user.fullName[0] : 'U',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.designation ?? user.semester ?? user.department,
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.rollNumber != null
                          ? 'Roll No: ${user.rollNumber}'
                          : user.employeeId != null
                              ? 'Emp ID: ${user.employeeId}'
                              : 'ID: ${user.id}',
                      style: const TextStyle(color: Colors.indigoAccent, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              // Mock Generated QR Code
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  size: 48,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),

          // Footer Validity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'VALIDITY: 2026-2027 ACADEMIC YEAR',
                style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold),
              ),
              Text(
                'VERIFIED IDENTITY',
                style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.redAccent;
      case UserRole.principal:
        return Colors.amberAccent;
      case UserRole.hod:
        return Colors.purpleAccent;
      case UserRole.faculty:
        return Colors.lightBlueAccent;
      case UserRole.student:
        return Colors.greenAccent;
    }
  }
}
