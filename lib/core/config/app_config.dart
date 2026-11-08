class AppConfig {
  static const String appNameEn = 'OneTools Studio';
  static const String appNameBn = 'ওয়ানটুলস স্টুডিও';
  static const String appVersion = '1.0.0';
  static const String developerCredit = 'OneTools Studio Team';

  static String getAppName(String lang) {
    return lang == 'bn' ? appNameBn : appNameEn;
  }

  static String getAppSubtitle(String lang) {
    return lang == 'bn'
        ? 'আপনার দৈনন্দিন সকল কাজের স্মার্ট অল-ইন-ওয়ান টুলবক্স'
        : 'Your All-in-One Smart Productivity Toolbox';
  }

  static String getAppDescription(String lang) {
    return lang == 'bn'
        ? 'ওয়ানটুলস স্টুডিও (OneTools Studio) - দৈনন্দিন হিসাব, গণিত, পিডিএফ, ছবি এডিটিং, ডেভেলপার ইউটিলিটি এবং ডিভাইস তথ্যের একটি সম্পূর্ণ অফলাইন অ্যাপ।'
        : 'OneTools Studio - A comprehensive offline-first utility toolbox for everyday productivity, math, document editing, developer tools, and device insights.';
  }
}
