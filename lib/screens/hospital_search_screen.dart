import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../models/hospital.dart';
import '../widgets/hospital_card.dart';
import '../widgets/custom_header.dart';

class HospitalSearchScreen extends StatefulWidget {
  const HospitalSearchScreen({super.key});

  @override
  State<HospitalSearchScreen> createState() => _HospitalSearchScreenState();
}

class _HospitalSearchScreenState extends State<HospitalSearchScreen> {
  // Mock Data
  final List<Hospital> _hospitals = [
    Hospital(
      name: '서울아산병원',
      rating: 4.5,
      reviewCount: 200,
      distance: 2.5,
      address: '서울특별시 송파구 올림픽로 43길 88',
      phoneNumber: '02-3010-0000',
      tags: ['심장내과', '응급실', '종합병원'],
      latitude: 0.0,
      longitude: 0.0,
      imageAsset: '',
    ),
    Hospital(
      name: '삼성서울병원',
      rating: 4.8,
      reviewCount: 350,
      distance: 5.1,
      address: '서울특별시 강남구 일원로 81',
      phoneNumber: '02-3410-2114',
      tags: ['심장센터', '세계적수준'],
      latitude: 0.0,
      longitude: 0.0,
      imageAsset: '',
    ),
    Hospital(
      name: '세브란스병원',
      rating: 4.7,
      reviewCount: 120,
      distance: 8.3,
      address: '서울특별시 서대문구 연세로 50',
      phoneNumber: '1599-1004',
      tags: ['심장혈관', '대학병원'],
      latitude: 0.0,
      longitude: 0.0,
      imageAsset: '',
    ),
    Hospital(
      name: '서울대학교병원',
      rating: 4.6,
      reviewCount: 400,
      distance: 10.5,
      address: '서울특별시 종로구 대학로 101',
      phoneNumber: '1588-5700',
      tags: ['국립대', '심장수술'],
      latitude: 0.0,
      longitude: 0.0,
      imageAsset: '',
    ),
    Hospital(
      name: '강남세브란스병원',
      rating: 4.4,
      reviewCount: 90,
      distance: 1.2,
      address: '서울특별시 강남구 언주로 211',
      phoneNumber: '02-2019-2114',
      tags: ['강남구', '응급실'],
      latitude: 0.0,
      longitude: 0.0,
      imageAsset: '',
    ),
  ];

  String _selectedRegion = '지역별로 찾기';

  // 논의 후 이중 드롭다운으로 변경하면 좋을 것 같아요
  // 시군구 - 동읍면
  void _showRegionFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final regions = ['강남역', '서울역', '수원역', '잠실역', '홍대입구역'];
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '지역 선택',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: regions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        regions[index],
                        style: GoogleFonts.notoSans(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedRegion = regions[index];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHeader(showBackButton: false),
      body: Stack(
        children: [
          Column(
            children: [
              // Top Filter Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_hospitals.length}개',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: _showRegionFilter,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _selectedRegion,
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
              // Hospital List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom:
                        150, // Add ample padding to avoid Nav Bar and FAB overlap
                  ),
                  itemCount: _hospitals.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final hospital = _hospitals[index];
                    return HospitalCard(
                      hospital: hospital,
                      onTap: () {
                        // Navigate to detail
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // Floating Map Button
          Positioned(
            bottom: 140, // Position above the CustomBottomNavBar
            right: 16, // Move to right
            child: FloatingActionButton.extended(
              onPressed: () {
                context.push('/hospitals');
              },
              backgroundColor: const Color(0xFF222222),
              icon: const Icon(Icons.map, color: Colors.white),
              label: Text(
                '지도에서 보기',
                style: GoogleFonts.notoSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
