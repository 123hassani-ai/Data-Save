import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/form_builder_provider.dart';
import '../../../core/providers/widget_library_provider.dart';
import '../../widgets/form_builder/widget_library_panel.dart';
import '../../widgets/form_builder/form_canvas.dart';
import '../../widgets/form_builder/properties_panel.dart';
import '../../widgets/form_builder/form_builder_app_bar.dart';

/// صفحه اصلی فرم‌ساز - Main Form Builder Page
/// رابط اصلی Form Builder UI Engine
class FormBuilderPage extends StatefulWidget {
  final int? formId; // برای ویرایش فرم موجود
  final int userId;

  const FormBuilderPage({
    super.key,
    this.formId,
    required this.userId,
  });

  @override
  State<FormBuilderPage> createState() => _FormBuilderPageState();
}

class _FormBuilderPageState extends State<FormBuilderPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // استفاده از Timer برای جلوگیری از خطای setState در initState
    Timer(Duration.zero, () async {
      await _initializeFormBuilder();
    });
  }

  /// مقداردهی اولیه فرم‌ساز
  Future<void> _initializeFormBuilder() async {
    try {
      final formBuilderProvider = context.read<FormBuilderProvider>();
      final widgetLibraryProvider = context.read<WidgetLibraryProvider>();

      // بارگذاری کتابخانه ویجت‌ها
      await widgetLibraryProvider.loadWidgetLibrary();

      // شروع فرم جدید یا بارگذاری فرم موجود
      if (widget.formId != null) {
        await formBuilderProvider.loadFormForEditing(widget.formId!, widget.userId);
      } else {
        formBuilderProvider.startNewForm(widget.userId);
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'در حال بارگذاری فرم‌ساز...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const FormBuilderAppBar(),
      body: _buildMainContent(context),
    );
  }

  /// ساخت محتوای اصلی صفحه
  Widget _buildMainContent(BuildContext context) {
    return Consumer<FormBuilderProvider>(
      builder: (context, formProvider, child) {
        final screenSize = MediaQuery.of(context).size;
        final isDesktop = screenSize.width > 1024;
        final isTablet = screenSize.width > 768 && screenSize.width <= 1024;
        final isMobile = screenSize.width <= 768;

        // Desktop Layout (>1024px)
        if (isDesktop) {
          return _buildDesktopLayout(formProvider);
        }
        
        // Tablet Layout (768-1024px) 
        if (isTablet) {
          return _buildTabletLayout(formProvider);
        }
        
        // Mobile Layout (<=768px)
        return _buildMobileLayout(formProvider);
      },
    );
  }

  /// طرح‌بندی دسکتاپ
  Widget _buildDesktopLayout(FormBuilderProvider formProvider) {
    return Row(
      children: [
        // Widget Library Panel (چپ)
        if (formProvider.isWidgetLibraryVisible)
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: const WidgetLibraryPanel(),
          ),
        
        // Form Canvas (وسط)
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            child: const FormCanvas(),
          ),
        ),
        
        // Properties Panel (راست)
        if (formProvider.isPropertiesPanelVisible)
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: const PropertiesPanel(),
          ),
      ],
    );
  }

  /// طرح‌بندی تبلت
  Widget _buildTabletLayout(FormBuilderProvider formProvider) {
    return Row(
      children: [
        // Widget Library Panel (چپ - کوچکتر)
        if (formProvider.isWidgetLibraryVisible)
          Container(
            width: 240,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: const WidgetLibraryPanel(),
          ),
        
        // Form Canvas (وسط)
        Expanded(
          child: Stack(
            children: [
              Container(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                child: const FormCanvas(),
              ),
              
              // Properties Panel به صورت Overlay
              if (formProvider.isPropertiesPanelVisible)
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  width: 280,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(-2, 0),
                        ),
                      ],
                    ),
                    child: const PropertiesPanel(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// طرح‌بندی موبایل
  Widget _buildMobileLayout(FormBuilderProvider formProvider) {
    return Stack(
      children: [
        // Form Canvas (پس‌زمینه)
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          child: const FormCanvas(),
        ),
        
        // Widget Library Panel به صورت Bottom Sheet
        if (formProvider.isWidgetLibraryVisible)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: const WidgetLibraryPanel(),
            ),
          ),
        
        // Properties Panel به صورت Side Sheet
        if (formProvider.isPropertiesPanelVisible)
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            width: MediaQuery.of(context).size.width * 0.85,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(-2, 0),
                  ),
                ],
              ),
              child: const PropertiesPanel(),
            ),
          ),
      ],
    );
  }
}
