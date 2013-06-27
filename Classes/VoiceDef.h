//
//  VoiceDef.h
//  Sanger
//
//  Created by JiaLi on 12-8-16.
//  Copyright (c) 2012年 Founder. All rights reserved.
//

#ifndef Sanger_VoiceDef_h
#define Sanger_VoiceDef_h



#endif

#ifdef DEBUG_
#define V_NSLog(format, ...)		NSLog(format, ##__VA_ARGS__)
#else
#define V_NSLog(format, ...)
#endif

#define APP_KEY_UMENG @"507fd3f75270150daf00005d"
#define NOTIFICATION_DOWNLOADED_VOICE_PKGXML   @"DownloadedVoicePkgXMLNotification"

#define NOTIFICATION_EDIT_VOICE_PKG @"EditPkgNotification"
#define NOTIFICATION_ADD_VOICE_PKG @"ADDPkgNotification"
#define NOTIFICATION_OPEN_PKG @"OpenPkgNotification"
#define NOTIFICATION_OPEN_LESSONS @"OpenLessonsNotification"
#define STRING_STORE_URL_ADDRESS @"http://isaybox.b0.upaiyun.com/index_ios.xml"
#define STRING_MY_DATA_CENTER @"我的资料库"
#define STRING_DATA_CENTER @"在线资料"
#define VALUE_TITLEBAR_COLOR_R 51.0/255.0
#define VALUE_TITLEBAR_COLOR_G 61.0/255.0
#define VALUE_TITLEBAR_COLOR_B 75.0/255.0
#define VALUE_DETAIL_STORE_BACKGROUND_COLOR1_R 247.0/255.0
#define VALUE_DETAIL_STORE_BACKGROUND_COLOR1_G 246.0/255.0
#define VALUE_DETAIL_STORE_BACKGROUND_COLOR1_B 242.0/255.0
#define VALUE_DETAIL_STORE_BACKGROUND_COLOR2_R 246.0/255.0
#define VALUE_DETAIL_STORE_BACKGROUND_COLOR2_G 242.0/255.0
#define VALUE_DETAIL_STORE_BACKGROUND_COLOR2_B 240.0/255.0
#define STRING_DATA_SAMPLE_1 @"出国必备"
#define STRING_DATA_SAMPLE_2 @"职场英语"
#define STRING_LOADINGDATA_WAITING @"正在载入..."
#define STRING_LOADINGDATA_ERROR @"网络连接错误"
#define STRING_DOWNLOAD         @"添加至“我的资料库”"
#define STRING_DOWNLOADING      @"正在添加"
#define STRING_START_LEARNING   @"开始学习"
#define STRING_DOWNLOADED       @"添加成功"
#define STRING_INTRO_TITLE      @"内容简介："
#define STRING_LESSONS_TITLE    @"课程内容："
#define STRING_DELETE           @"删除"
#define STRING_UNDO             @"返回"
#define STRING_DELETEBOOK_ALERT_MESSAGE @"您确定要删除添加的资料《%@》吗?"
#define STRING_DELETEBOOK_ALERT_TITLE   @"删除资料"
#define STRING_DELETEBOOK_BUTTON_CONFIRM @"确认"
#define STRING_DELETEBOOK_BUTTON_CANCEL @"取消"
#define STRING_COURSE_INDEX @"课程"
#define STRING_VOICE_PKG_DIR    @"VoicePkgData"
#define SUB_DIR_DOCUMENT				@"/Documents/"
#define SUB_DIR_CACHE                   @"/Caches/"

#define kBufferDurationSeconds 1.0

#define TAG_OF_TIME_INTEVAL 40000
#define TAG_OF_READING_COUNT 40001

#define FONT_SIZE_BUBBLE 17.0
#define FONT_SIZE 18.0f
#define CELL_CONTENT_MARGIN 10.0f
#define MAGIN_OF_TEXTANDTRANSLATE 2.0
#define MAX_RATING 5.0
#define MAGIN_OF_BUBBLE_ICON_START 24.0
#define MAGIN_OF_BUBBLE_TEXT_START 15.0
#define IS_IPAD	([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define MAGIN_OF_LESSON_TITLE  64
#define MAGIN_OF_RIGHT         40
#define kBufferDurationSeconds 1.0


#define KEY_SETTING_USE_COVERFLOW                   @"UICoverFlow"
#define KEY_SETTING_LESSONCELLSTYLE                 @"UILessonCellStyle"
#define KEY_SETTING_NAVIGATIONCOLOR                 @"UINavigationColor"
#define KEY_SETTING_LESSON_PAGINATION               @"UILessonPagination"
#define KEY_SETTING_LESSON_PAGE_OF_IPHONE           @"UILessonPageCountOfiPhone"
#define KEY_SETTING_LESSON_PAGE_OF_IPAD             @"UILessonPageCountOfiPad"
#define KEY_SETTING_SHOWTRANLATION                  @"UIShowTranslation"
#define KEY_SETTING_TEACHERHEAD_STYLE               @"UITeacherHeadStyle"
#define KEY_SETTING_SHOWAD_STORE                    @"AD_Store"
#define KEY_SETTING_SHOWAD_DAY_BY_DAY               @"AD_Day"
#define KEY_SETTING_SHOWAD_COURSE                   @"AD_Course"
#define KEY_SETTING_SHOWAD_LESSON                   @"AD_Lesson"
#define KEY_SETTING_SHOWAD_RECORDING                @"AD_Recording"


#define NOTI_CHANGED_SETTING_VALUE      @"ChangedSettingValueNotification"
#define NOTI_WILLENTERFOREGROUND        @"WillEnterForegroundNotification"
#define STRING_RESOURCE_DATA            @"Data"
#define STRING_LESSONS_INDEX_XML        @"index.xml"
#define PATH_USERDATA                   @"/UserData"
#define DIR_SETTING                     @"Setting"
#define FILE_SETTING_PLIST				@"setting.plist"
#define FILE_DAYTIME_PLIST				@"daytime.plist"
#define DIR_DATABASE                    @"Database"
#define DATABASE_NAME                   @"db.sqlite"
#define STRING_SCENE_TITLE              @"场景"
#define STRING_SETTING_TITLE            @"设置"
#define STRING_SETTING_READING          @"朗读设置"
#define STRING_SETTING_TIME             @"时间间隔"
#define STRING_SETTING_BUBBLE           @"对话设置"
#define STRING_COLOR_1                  @"对话一"
#define STRING_COLOR_2                  @"对话二"
#define STRING_COLOR_3                  @"对话三"
#define STRING_SHOW_TRANSLATION         @"显示译文"
#define STRING_SCORE_STRING             @"(%.1f 分)"
#define STRING_RECORDING                @"录音"
#define STRING_LISTENING                @"朗读"
#define STRING_BACK                     @"返回"

#define STRING_TRANING_MODE             @"训练模式设置"
#define STRING_CONTROL_SETTING          @"控制设置"
#define STRING_SHOW_MODE                @"显示设置"
#define STRING_WHOLE_LESSON_MODE        @"全文试听"
#define STRING_SENTENCE_MODE            @"跟读训练"
#define STRING_READING_COUNT            @"跟读次数"
#define STRING_READING_COUNT_FORMAT     @"%d次"
#define STRING_TIME_DE_COUNT_FORMAT     @"%.1f秒"

#define STRING_SHOW_SRC_TEXT            @"显示原文"
#define STRING_SHOW_SRCANDTRANS_TEXT    @"显示原文和译文"
#define STRING_SHOW_NO_TEXT             @"不显示"
#define STRING_SETTING_LOOP_TEXT        @"循环朗读全文"

#define STRING_DAY                      @"每日一句"
#define STRING_DAY_CONTROL              @"开启每日一句"
#define STRING_DAY_CONTROL_OPEN         @"开启"
#define STRING_DAY_CONTROL_CLOSE        @"关闭"
#define STRING_DAY_PROMPT               @"(上方可关闭每日一句的显示，在设置里可重新开启每日一句)"
#define STRING_OTHER                    @"其他"
#define STRING_ABOUT_US                 @"关于我们"
#define STRING_ABOUT_VERSION            @"版本号"
#define STRING_ABOUT_US_TILTE           @""
#define STRING_ABOUT_DETAIL             @"  "
#define STRING_START_RECORDING          @"开始录音"
#define STRING_STOP_RECORDING           @"停止录音"
#define STRING_PREVIOUS_SENTENCE        @"上一句"
#define STRING_NEXT_SENTENCE            @"下一句"
#define STRING_SINGLE_TRAINING          @"单句训练"

#define STRING_SRC_TEXT                 @"原文显示"
#define STRING_VOICE_GRAPHIC            @"波形对比"
#define STRING_LOADING_TEXT             @"第一次初始化课程..."
#define STRING_WAITING_TEXT             @"正在加载..."
#define STRING_DOWNLOADING_TEXT         @"正在下载课程..."
#define STRING_DOWNLOADING_FAILED_TEXT  @"下载失败，请重试."
#define STRING_RECORDING_ERROR          @"录音失败，请检查设备"
#define STRING_RECORDING_TEXT           @"正在录音..."
#define STRING_SETTING                  @"设置"
#define STRING_PRE_PAGE                 @"上一页"
#define STRING_NEXT_PAGE                @"下一页"
#define PS_ARRAY	@"ai,au,εə,i:,a:,ɔ:,u:,i,e,æ,ə,ʌ,ɔ,u,θ,ʃ,tʃ,tr,dʒ,dr,ŋ,ð,p,t,k,f,s,h,b,d,g,v,d,z,r,w,m,n,l"
#define PS_CHAR_ARRAY @"ah ih,ah uh,eh ex,ii,aa,oo,uu,ih,eh,ae,ex,ah,oh,uh,th,sh,tg,tr,zh,dr,ng,dh,pp,tt,kk,ff,ss,hh,bb,dd,gg,vv,dd,zz,rr,ww,mm,nn,ll"
#define DAYBYDY_TITLE                   @"每日一句"

#define PERSONAL_INFO                   @"个人信息"
#define STRING_ENTER_LIB_ADDRESS        @"请输入图书馆地址"

#define MAIN_COURSE_GRID_W              90
#define MAIN_COURSE_GRID_H              60
#define MAIN_COURSE_GRID_W_IPAD         120
#define MAIN_COURSE_GRID_H_IPAD          90
