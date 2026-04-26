import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final String label;
  final String labelNp;
  final IconData icon;

  const ServiceCategory({
    required this.id,
    required this.label,
    required this.labelNp,
    required this.icon,
  });
}

const List<ServiceCategory> serviceCategories = [
  ServiceCategory(id: 'plumber', label: 'Plumber', labelNp: 'प्लम्बर', icon: Icons.plumbing),
  ServiceCategory(id: 'electrician', label: 'Electrician', labelNp: 'इलेक्ट्रिशियन', icon: Icons.electrical_services),
  ServiceCategory(id: 'tutor', label: 'Tutor', labelNp: 'ट्युटर', icon: Icons.school),
  ServiceCategory(id: 'carpenter', label: 'Carpenter', labelNp: 'काठ मिस्त्री', icon: Icons.carpenter),
  ServiceCategory(id: 'painter', label: 'Painter', labelNp: 'रंगकर्मी', icon: Icons.format_paint),
  ServiceCategory(id: 'tailor', label: 'Tailor', labelNp: 'दर्जी', icon: Icons.content_cut),
  ServiceCategory(id: 'cleaner', label: 'Cleaner', labelNp: 'सफाइकर्मी', icon: Icons.cleaning_services),
  ServiceCategory(id: 'driver', label: 'Driver', labelNp: 'चालक', icon: Icons.drive_eta),
  ServiceCategory(id: 'cook', label: 'Cook', labelNp: 'भान्से', icon: Icons.restaurant),
  ServiceCategory(id: 'mason', label: 'Mason', labelNp: 'डकर्मी', icon: Icons.construction),
  ServiceCategory(id: 'mechanic', label: 'Mechanic', labelNp: 'मेकानिक', icon: Icons.build),
  ServiceCategory(id: 'gardener', label: 'Gardener', labelNp: 'माली', icon: Icons.grass),
  ServiceCategory(id: 'other', label: 'Other', labelNp: 'अन्य', icon: Icons.more_horiz),
];

const List<String> nepalDistricts = [
  'Achham', 'Arghakhanchi', 'Baglung', 'Baitadi', 'Bajhang', 'Bajura',
  'Banke', 'Bara', 'Bardiya', 'Bhaktapur', 'Bhojpur', 'Chitwan',
  'Dadeldhura', 'Dailekh', 'Dang', 'Darchula', 'Dhading', 'Dhankuta',
  'Dhanusa', 'Dolakha', 'Dolpa', 'Doti', 'Eastern Rukum', 'Gorkha',
  'Gulmi', 'Humla', 'Ilam', 'Jajarkot', 'Jhapa', 'Jumla', 'Kailali',
  'Kalikot', 'Kanchanpur', 'Kapilvastu', 'Kaski', 'Kathmandu',
  'Kavrepalanchok', 'Khotang', 'Lalitpur', 'Lamjung', 'Mahottari',
  'Makwanpur', 'Manang', 'Morang', 'Mugu', 'Mustang', 'Myagdi',
  'Nawalparasi East', 'Nawalparasi West', 'Nuwakot', 'Okhaldhunga',
  'Palpa', 'Panchthar', 'Parbat', 'Parsa', 'Pyuthan', 'Ramechhap',
  'Rasuwa', 'Rautahat', 'Rolpa', 'Rupandehi', 'Salyan', 'Sankhuwasabha',
  'Saptari', 'Sarlahi', 'Sindhuli', 'Sindhupalchok', 'Siraha',
  'Solukhumbu', 'Sunsari', 'Surkhet', 'Syangja', 'Taplejung',
  'Terhathum', 'Udayapur', 'Western Rukum',
];

const List<String> weekDays = [
  'sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday',
];

const List<String> weekDaysNp = [
  'आइतबार', 'सोमबार', 'मंगलबार', 'बुधबार', 'बिहीबार', 'शुक्रबार', 'शनिबार',
];

const List<String> weekDaysEn = [
  'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
];

String getCategoryLabel(String id, {bool nepali = false}) {
  final cat = serviceCategories.firstWhere(
    (c) => c.id == id,
    orElse: () => const ServiceCategory(
      id: 'other', label: 'Other', labelNp: 'अन्य', icon: Icons.more_horiz,
    ),
  );
  return nepali ? cat.labelNp : cat.label;
}
