import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/tool_categories.dart';
import '../../core/localization/localization_provider.dart';
import '../../core/providers/history_provider.dart';

// Import all specific tool screen files
import 'calculator_math/calculator_tools_screen.dart';

// Math & Finance subfolder imports
import 'calculator_math/math_tools/finance/compound_interest_screen.dart';
import 'calculator_math/math_tools/finance/simple_interest_screen.dart';
import 'calculator_math/math_tools/finance/gst_vat_screen.dart';
import 'calculator_math/math_tools/finance/sip_calculator_screen.dart';
import 'calculator_math/math_tools/finance/loan_eligibility_screen.dart';
import 'calculator_math/math_tools/finance/inflation_salary_screen.dart';
import 'calculator_math/math_tools/finance/tip_split_bill_screen.dart';

import 'calculator_math/math_tools/algebra/matrix_calculator_screen.dart';
import 'calculator_math/math_tools/algebra/gcd_lcm_screen.dart';
import 'calculator_math/math_tools/algebra/npr_ncr_screen.dart';
import 'calculator_math/math_tools/algebra/logarithm_screen.dart';
import 'calculator_math/math_tools/algebra/quadratic_solver_screen.dart';
import 'calculator_math/math_tools/algebra/statistics_calculator_screen.dart';
import 'calculator_math/math_tools/algebra/ap_gp_series_screen.dart';

import 'calculator_math/math_tools/geometry/shape_2d_area_screen.dart';
import 'calculator_math/math_tools/geometry/shape_3d_volume_screen.dart';
import 'calculator_math/math_tools/geometry/pythagoras_solver_screen.dart';
import 'calculator_math/math_tools/geometry/trigonometry_solver_screen.dart';

import 'calculator_math/math_tools/health/ideal_weight_screen.dart';
import 'calculator_math/math_tools/health/calorie_macro_screen.dart';
import 'calculator_math/math_tools/health/body_fat_screen.dart';
import 'calculator_math/math_tools/health/water_intake_screen.dart';

import 'calculator_math/math_tools/time_utility/time_math_screen.dart';
import 'calculator_math/math_tools/time_utility/timezone_converter_screen.dart';
import 'calculator_math/math_tools/time_utility/fuel_mileage_screen.dart';
import 'calculator_math/math_tools/time_utility/tally_counter_screen.dart';

import 'calculator_math/math_tools/percentage_calculator_screen.dart';
import 'calculator_math/math_tools/discount_calculator_screen.dart';
import 'calculator_math/math_tools/profit_loss_calculator_screen.dart';
import 'calculator_math/math_tools/emi_calculator_screen.dart';
import 'calculator_math/math_tools/bmi_calculator_screen.dart';
import 'calculator_math/math_tools/bmr_calculator_screen.dart';
import 'calculator_math/math_tools/gpa_calculator_screen.dart';
import 'calculator_math/math_tools/fraction_calculator_screen.dart';
import 'calculator_math/math_tools/ratio_calculator_screen.dart';
import 'calculator_math/math_tools/average_calculator_screen.dart';
import 'calculator_math/math_tools/number_system_converter_screen.dart';
import 'calculator_math/math_tools/equation_solver_screen.dart';
import 'calculator_math/math_tools/random_generator_screen.dart';
import 'calculator_math/math_tools/prime_checker_screen.dart';
import 'calculator_math/math_tools/factorial_calculator_screen.dart';

import 'pdf_document/pdf_tools_screen.dart';
import 'image_photo/image_tools_screen.dart';
import 'qr_barcode/qr_tools_screen.dart';
import 'developer/developer_tools_screen.dart';
import 'internet_network/network_tools_screen.dart';
import 'student_education/student_tools_screen.dart';
import 'daily_productivity/productivity_tools_screen.dart';
import 'measurement_conversion/conversion_tools_screen.dart';
import 'audio_video/media_tools_screen.dart';
import 'finance_business/finance_tools_screen.dart';
import 'text_ai/text_ai_screen.dart';
import 'security_privacy/security_tools_screen.dart';
import 'gps_location/gps_tools_screen.dart';
import 'file_storage/file_tools_screen.dart';
import 'mobile_device/device_tools_screen.dart';

class ToolScreenDispatcher {
  static void openTool(BuildContext context, WidgetRef ref, String toolId) {
    // Record tool in history
    ref.read(historyProvider.notifier).addToolToHistory(toolId);

    Widget screen;
    switch (toolId) {
      // 1. Calculator & Math
      case 'basic_calc':
        screen = const BasicCalculatorScreen();
        break;

      case 'scientific_calc':
        screen = const ScientificCalculatorScreen();
        break;

      case 'percentage_calc':
        screen = const PercentageCalculatorScreen();
        break;

      case 'discount_calc':
        screen = const DiscountCalculatorScreen();
        break;

      case 'profit_loss_calc':
        screen = const ProfitLossCalculatorScreen();
        break;

      case 'emi_calc':
        screen = const EmiCalculatorScreen();
        break;

      case 'bmi_calc':
        screen = const BmiCalculatorScreen();
        break;

      case 'bmr_calc':
        screen = const BmrCalculatorScreen();
        break;

      case 'gpa_calc':
        screen = const GpaCalculatorScreen();
        break;

      case 'fraction_calc':
        screen = const FractionCalculatorScreen();
        break;

      case 'ratio_calc':
        screen = const RatioCalculatorScreen();
        break;

      case 'average_calc':
        screen = const AverageCalculatorScreen();
        break;

      case 'number_system_converter':
        screen = const NumberSystemConverterScreen();
        break;

      case 'equation_solver':
        screen = const EquationSolverScreen();
        break;

      case 'random_generator':
        screen = const RandomGeneratorScreen();
        break;

      case 'prime_checker':
        screen = const PrimeCheckerScreen();
        break;

      case 'factorial_calc':
        screen = const FactorialCalculatorScreen();
        break;

      case 'compound_interest_calc':
        screen = const CompoundInterestScreen();
        break;

      case 'simple_interest_calc':
        screen = const SimpleInterestScreen();
        break;

      case 'gst_vat_tax_calc':
        screen = const GstVatScreen();
        break;

      case 'sip_mutual_fund_calc':
        screen = const SipCalculatorScreen();
        break;

      case 'loan_eligibility_calc':
        screen = const LoanEligibilityScreen();
        break;

      case 'inflation_salary_calc':
        screen = const InflationSalaryScreen();
        break;

      case 'tip_split_bill_calc':
        screen = const TipSplitBillScreen();
        break;

      case 'matrix_determinant_calc':
        screen = const MatrixCalculatorScreen();
        break;

      case 'gcd_lcm_calc':
        screen = const GcdLcmScreen();
        break;

      case 'npr_ncr_calc':
        screen = const NprNcrScreen();
        break;

      case 'logarithm_calc':
        screen = const LogarithmScreen();
        break;

      case 'quadratic_equation_solver':
        screen = const QuadraticSolverScreen();
        break;

      case 'statistics_calc':
        screen = const StatisticsCalculatorScreen();
        break;

      case 'ap_gp_series_calc':
        screen = const ApGpSeriesScreen();
        break;

      case 'area_2d_shape_calc':
        screen = const Shape2dAreaScreen();
        break;

      case 'volume_3d_shape_calc':
        screen = const Shape3dVolumeScreen();
        break;

      case 'pythagoras_triangle_calc':
        screen = const PythagorasSolverScreen();
        break;

      case 'trigonometry_solver':
        screen = const TrigonometrySolverScreen();
        break;

      case 'ideal_body_weight_calc':
        screen = const IdealWeightScreen();
        break;

      case 'calorie_macro_calc':
        screen = const CalorieMacroScreen();
        break;

      case 'body_fat_percentage_calc':
        screen = const BodyFatScreen();
        break;

      case 'water_intake_calc':
        screen = const WaterIntakeScreen();
        break;

      case 'time_math_calc':
        screen = const TimeMathScreen();
        break;

      case 'timezone_converter_calc':
        screen = const TimezoneConverterScreen();
        break;

      case 'fuel_cost_mileage_calc':
        screen = const FuelMileageScreen();
        break;

      case 'tally_counter_tool':
        screen = const TallyCounterScreen();
        break;

      // 2. PDF & Document
      case 'image_to_pdf':
      case 'photo_to_pdf':
        screen = const ImageToPdfScreen();
        break;

      case 'pdf_merger':
        screen = const PdfMergerScreen();
        break;

      case 'pdf_splitter':
        screen = const PdfSplitterScreen();
        break;

      case 'pdf_page_rotator':
      case 'pdf_page_reorder':
        screen = const PdfPageRotatorScreen();
        break;

      case 'pdf_compressor':
        screen = const PdfCompressorScreen();
        break;

      case 'pdf_lock_unlock':
        screen = const PdfLockUnlockScreen();
        break;

      case 'watermark_pdf':
        screen = const WatermarkPdfScreen();
        break;

      case 'signature_maker':
        screen = const SignatureMakerScreen();
        break;

      case 'ocr_text':
        screen = const OcrTextScreen();
        break;

      case 'pdf_text_extractor':
        screen = const TextExtractorScreen();
        break;

      case 'id_card_scanner':
      case 'doc_scanner':
      case 'qr_to_pdf':
        screen = const IdCardScannerScreen();
        break;

      case 'pdf_metadata_viewer':
        screen = const PdfMetadataViewerScreen();
        break;

      case 'pdf_page_counter':
      case 'pdf_to_image':
        screen = const PdfMetadataScreen();
        break;

      case 'pdf_reader':
        screen = const PdfReaderScreen();
        break;

      case 'word_to_pdf':
        screen = const WordToPdfScreen();
        break;

      case 'doc_converter':
        screen = const WordDocConverterScreen();
        break;

      // 3. Image & Photo
      case 'color_picker':
        screen = const ColorPickerScreen();
        break;

      case 'image_compressor':
        screen = const ImageCompressorScreen();
        break;

      case 'image_resizer':
        screen = const ImageResizerScreen();
        break;

      case 'image_cropper':
      case 'image_rotator':
      case 'bg_remover':
        screen = const ImageResizerCompressorScreen();
        break;

      case 'format_converter':
      case 'jpg_to_png':
      case 'png_to_jpg':
      case 'webp_converter':
        screen = const FormatConverterScreen();
        break;

      case 'passport_photo_maker':
      case 'nid_photo_resizer':
        screen = const PassportNidPhotoScreen();
        break;

      case 'photo_filters':
        screen = const PhotoFiltersScreen();
        break;

      case 'blur_image':
      case 'pixelate_image':
      case 'image_watermark':
      case 'collage_maker':
      case 'meme_generator':
      case 'screenshot_editor':
        screen = const PhotoFiltersEditorScreen();
        break;

      case 'exif_viewer':
      case 'image_to_base64':
        screen = const ExifMetadataBase64Screen();
        break;

      // 4. QR & Barcode
      case 'qr_generator':
      case 'wifi_qr':
      case 'contact_qr':
      case 'url_qr':
      case 'text_qr':
      case 'payment_qr':
      case 'qr_exporter':
      case 'vcard_qr':
        screen = const QrGeneratorScreen();
        break;

      case 'qr_scanner':
      case 'qr_history':
        screen = const QrScannerScreen();
        break;

      case 'barcode_generator':
      case 'barcode_scanner':
      case 'product_barcode':
        screen = const BarcodeGeneratorScreen();
        break;

      // 5. Developer Tools
      case 'json_formatter':
      case 'json_validator':
      case 'json_minifier':
      case 'xml_formatter':
      case 'html_formatter':
      case 'css_minifier':
      case 'js_minifier':
      case 'sql_formatter':
        screen = const JsonFormatterScreen();
        break;

      case 'json_to_dart':
      case 'json_to_kotlin':
      case 'flutter_code_snippets':
      case 'dart_formatter':
        screen = const JsonToModelScreen();
        break;

      case 'base64_tool':
      case 'url_encoder':
      case 'hash_generator':
      case 'uuid_generator':
      case 'color_code_converter':
      case 'css_gradient_generator':
      case 'box_shadow_generator':
      case 'lorem_generator':
        screen = const HashUuidGeneratorScreen();
        break;

      case 'jwt_decoder':
      case 'timestamp_converter':
      case 'cron_helper':
        screen = const JwtTimestampDecoderScreen();
        break;

      case 'git_cheat_sheet':
      case 'http_status_codes':
      case 'regex_tester':
      case 'api_tester':
      case 'markdown_previewer':
        screen = const DevCheatsheetsScreen();
        break;

      // 6. Internet & Network
      case 'speed_test':
      case 'ping_test':
      case 'net_monitor':
      case 'data_usage':
      case 'port_checker':
      case 'website_availability':
      case 'url_redirect':
      case 'ssl_checker':
        screen = const SpeedTestScreen();
        break;

      case 'public_ip':
      case 'ip_info':
      case 'wifi_details':
      case 'dns_lookup':
      case 'http_headers':
      case 'whois_lookup':
      case 'subnet_calc':
      case 'mac_formatter':
        screen = const IpViewerScreen();
        break;

      // 7. Student & Education
      case 'question_paper_generator':
        screen = const QuestionPaperGeneratorScreen();
        break;

      case 'certificate_maker':
        screen = const CertificateMakerScreen();
        break;

      case 'notice_circular_generator':
        screen = const NoticeCircularGeneratorScreen();
        break;

      case 'class_routine':
        screen = const ClassRoutineMakerScreen();
        break;

      case 'student_id_card_maker':
        screen = const StudentIdCardMakerScreen();
        break;

      case 'leave_application_generator':
        screen = const LeaveApplicationGeneratorScreen();
        break;

      case 'student_gpa':
      case 'student_cgpa':
      case 'attendance_calc':
      case 'study_timetable':
      case 'exam_countdown':
      case 'assignment_tracker':
        screen = const StudentGpaScreen();
        break;

      case 'word_counter':
      case 'character_counter':
      case 'reading_time_calc':
      case 'typing_test':
      case 'dictionary_tool':
      case 'physics_formulas':
      case 'study_notes':
      case 'flashcard_maker':
        screen = const WordCounterScreen();
        break;

      case 'pomodoro_timer':
        screen = const PomodoroTimerScreen();
        break;

      // 8. Daily Productivity
      case 'todo_list':
      case 'notes_app':
      case 'reminder_app':
      case 'habit_tracker':
      case 'bill_splitter':
      case 'decision_wheel':
      case 'text_case_converter':
      case 'text_repeater':
        screen = const TodoListScreen();
        break;

      case 'password_generator':
      case 'flashlight_tool':
      case 'stopwatch_timer':
      case 'world_clock':
        screen = const PasswordGeneratorScreen();
        break;

      // 9. Measurement & Conversion
      case 'unit_converter':
      case 'digital_ruler':
        screen = const UnitConverterScreen();
        break;

      case 'currency_converter':
        screen = const CurrencyConverterScreen();
        break;

      // 10. Audio & Video
      case 'voice_recorder':
      case 'media_metadata':
        screen = const VoiceRecorderScreen();
        break;

      // 11. Finance & Business
      case 'budget_calculator':
      case 'interest_calculator':
      case 'tax_vat_calculator':
      case 'invoice_generator':
        screen = const BudgetCalculatorScreen();
        break;

      // 12. Text & AI
      case 'bangla_unicode':
      case 'text_to_speech':
        screen = const BanglaUnicodeScreen();
        break;

      case 'ai_chat_assistant':
        screen = const AiAssistantScreen();
        break;

      // 13. Security
      case 'totp_authenticator':
      case 'secure_notes':
        screen = const TotpAuthenticatorScreen();
        break;

      // 14. GPS
      case 'gps_coordinates':
      case 'speedometer':
        screen = const GpsSpeedometerScreen();
        break;

      // 15. File
      case 'zip_extractor':
      case 'file_editor':
        screen = const FileEditorScreen();
        break;

      // 16. Device
      case 'device_info':
      case 'hardware_tester':
        screen = const DeviceSpecsScreen();
        break;

      default:
        final tool = ToolCategories.getToolById(toolId);
        final lang = ref.read(languageProvider);
        screen = Scaffold(
          appBar: AppBar(title: Text(tool.getTitle(lang))),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(tool.icon, size: 80, color: Colors.blue),
                const SizedBox(height: 16),
                Text(
                  tool.getTitle(lang),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    tool.getDescription(lang),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Tool Initialized & Ready'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
