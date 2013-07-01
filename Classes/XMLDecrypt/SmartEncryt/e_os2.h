/* e_os2.h */

// #include <cryptconf.h>

#ifndef HEADER_E_OS2_H
#define HEADER_E_OS2_H

#ifdef  __cplusplus
extern "C" {
#endif

/******************************************************************************
 * Detect operating systems.  This probably needs completing.
 * The result is that at least one DAVINCI_SYS_os macro should be defined.
 * However, if none is defined, Unix is assumed.
 **/

#define DAVINCI_SYS_UNIX

/* ----------------------- Macintosh, before MacOS X ----------------------- */
#if defined(__MWERKS__) && defined(macintosh) || defined(DAVINCI_SYSNAME_MAC)
# undef DAVINCI_SYS_UNIX
# define DAVINCI_SYS_MACINTOSH_CLASSIC
#endif

/* ----------------------- NetWare ----------------------------------------- */
#if defined(NETWARE) || defined(DAVINCI_SYSNAME_NETWARE)
# undef DAVINCI_SYS_UNIX
# define DAVINCI_SYS_NETWARE
#endif

/* ---------------------- Microsoft operating systems ---------------------- */

/* Note that MSDOS actually denotes 32-bit environments running on top of
   MS-DOS, such as DJGPP one. */
#if defined(DAVINCI_SYSNAME_MSDOS)
# undef DAVINCI_SYS_UNIX
# define DAVINCI_SYS_MSDOS
#endif

/* For 32 bit environment, there seems to be the CygWin environment and then
   all the others that try to do the same thing Microsoft does... */
#if defined(DAVINCI_SYSNAME_UWIN)
# undef DAVINCI_SYS_UNIX
# define DAVINCI_SYS_WIN32_UWIN
#else
# if defined(__CYGWIN32__) || defined(DAVINCI_SYSNAME_CYGWIN32)
#  undef DAVINCI_SYS_UNIX
#  define DAVINCI_SYS_WIN32_CYGWIN
# else
#  if defined(_WIN32) || defined(DAVINCI_SYSNAME_WIN32)
#   undef DAVINCI_SYS_UNIX
#   define DAVINCI_SYS_WIN32
#  endif
#  if defined(DAVINCI_SYSNAME_WINNT)
#   undef DAVINCI_SYS_UNIX
#   define DAVINCI_SYS_WINNT
#  endif
#  if defined(DAVINCI_SYSNAME_WINCE)
#   undef DAVINCI_SYS_UNIX
#   define DAVINCI_SYS_WINCE
#  endif
# endif
#endif

/* Anything that tries to look like Microsoft is "Windows" */
#if defined(DAVINCI_SYS_WIN32) || defined(DAVINCI_SYS_WINNT) || defined(DAVINCI_SYS_WINCE)
# undef DAVINCI_SYS_UNIX
# define DAVINCI_SYS_WINDOWS
# ifndef DAVINCI_SYS_MSDOS
#  define DAVINCI_SYS_MSDOS
# endif
#endif

/* DLL settings.  This part is a bit tough, because it's up to the application
   implementor how he or she will link the application, so it requires some
   macro to be used. */
#ifdef DAVINCI_SYS_WINDOWS
# ifndef DAVINCI_OPT_WINDLL
#  if defined(_WINDLL) /* This is used when building DAVINCI to indicate that
                          DLL linkage should be used */
#   define DAVINCI_OPT_WINDLL
#  endif
# endif
#endif

/* -------------------------------- OpenVMS -------------------------------- */
#if defined(__VMS) || defined(VMS) || defined(DAVINCI_SYSNAME_VMS)
# undef DAVINCI_SYS_UNIX
# define DAVINCI_SYS_VMS
# if defined(__DECC)
#  define DAVINCI_SYS_VMS_DECC
# elif defined(__DECCXX)
#  define DAVINCI_SYS_VMS_DECC
#  define DAVINCI_SYS_VMS_DECCXX
# else
#  define DAVINCI_SYS_VMS_NODECC
# endif
#endif

/* --------------------------------- OS/2 ---------------------------------- */
#if defined(__EMX__) || defined(__OS2__)
# undef DAVINCI_SYS_UNIX
# define DAVINCI_SYS_OS2
#endif

/* --------------------------------- Unix ---------------------------------- */
#ifdef DAVINCI_SYS_UNIX
# if defined(linux) || defined(__linux__) || defined(DAVINCI_SYSNAME_LINUX)
#  define DAVINCI_SYS_LINUX
# endif
# ifdef DAVINCI_SYSNAME_MPE
#  define DAVINCI_SYS_MPE
# endif
# ifdef DAVINCI_SYSNAME_SNI
#  define DAVINCI_SYS_SNI
# endif
# ifdef DAVINCI_SYSNAME_ULTRASPARC
#  define DAVINCI_SYS_ULTRASPARC
# endif
# ifdef DAVINCI_SYSNAME_NEWS4
#  define DAVINCI_SYS_NEWS4
# endif
# ifdef DAVINCI_SYSNAME_MACOSX
#  define DAVINCI_SYS_MACOSX
# endif
# ifdef DAVINCI_SYSNAME_MACOSX_RHAPSODY
#  define DAVINCI_SYS_MACOSX_RHAPSODY
#  define DAVINCI_SYS_MACOSX
# endif
# ifdef DAVINCI_SYSNAME_SUNOS
#  define DAVINCI_SYS_SUNOS
#endif
# if defined(_CRAY) || defined(DAVINCI_SYSNAME_CRAY)
#  define DAVINCI_SYS_CRAY
# endif
# if defined(_AIX) || defined(DAVINCI_SYSNAME_AIX)
#  define DAVINCI_SYS_AIX
# endif
#endif

/* --------------------------------- VOS ----------------------------------- */
#ifdef DAVINCI_SYSNAME_VOS
# define DAVINCI_SYS_VOS
#endif

/* ------------------------------- VxWorks --------------------------------- */
#ifdef DAVINCI_SYSNAME_VXWORKS
# define DAVINCI_SYS_VXWORKS
#endif

/**
 * That's it for OS-specific stuff
 *****************************************************************************/


/* Specials for I/O an exit */
#ifdef DAVINCI_SYS_MSDOS
# define DAVINCI_UNISTD_IO <io.h>
# define DAVINCI_DECLARE_EXIT extern void exit(int);
#else
# define DAVINCI_UNISTD_IO DAVINCI_UNISTD
# define DAVINCI_DECLARE_EXIT /* declared in unistd.h */
#endif

/* Definitions of DAVINCI_GLOBAL and DAVINCI_EXTERN, to define and declare
   certain global symbols that, with some compilers under VMS, have to be
   defined and declared explicitely with globaldef and globalref.
   Definitions of DAVINCI_EXPORT and DAVINCI_IMPORT, to define and declare
   DLL exports and imports for compilers under Win32.  These are a little
   more complicated to use.  Basically, for any library that exports some
   global variables, the following code must be present in the header file
   that declares them, before DAVINCI_EXTERN is used:

   #ifdef SOME_BUILD_FLAG_MACRO
   # undef DAVINCI_EXTERN
   # define DAVINCI_EXTERN DAVINCI_EXPORT
   #endif

   The default is to have DAVINCI_EXPORT, DAVINCI_IMPORT and DAVINCI_GLOBAL
   have some generally sensible values, and for DAVINCI_EXTERN to have the
   value DAVINCI_IMPORT.
*/

#if defined(DAVINCI_SYS_VMS_NODECC)
# define DAVINCI_EXPORT globalref
# define DAVINCI_IMPORT globalref
# define DAVINCI_GLOBAL globaldef
#elif defined(DAVINCI_SYS_WINDOWS) && defined(DAVINCI_OPT_WINDLL)
# define DAVINCI_EXPORT extern __declspec(dllexport)
# define DAVINCI_IMPORT extern __declspec(dllimport)
# define DAVINCI_GLOBAL
#else
# define DAVINCI_EXPORT extern
# define DAVINCI_IMPORT extern
# define DAVINCI_GLOBAL
#endif
#define DAVINCI_EXTERN DAVINCI_IMPORT

/* Macros to allow global variables to be reached through function calls when
   required (if a shared library version requvres it, for example.
   The way it's done allows definitions like this:

	// in foobar.c
	DAVINCI_IMPLEMENT_GLOBAL(int,foobar) = 0;
	// in foobar.h
	DAVINCI_DECLARE_GLOBAL(int,foobar);
	#define foobar DAVINCI_GLOBAL_REF(foobar)
*/
#ifdef DAVINCI_EXPORT_VAR_AS_FUNCTION
# define DAVINCI_IMPLEMENT_GLOBAL(type,name)			     \
	extern type _hide_##name;				     \
	type *_shadow_##name(void) { return &_hide_##name; }	     \
	static type _hide_##name
# define DAVINCI_DECLARE_GLOBAL(type,name) type *_shadow_##name(void)
# define DAVINCI_GLOBAL_REF(name) (*(_shadow_##name()))
#else
# define DAVINCI_IMPLEMENT_GLOBAL(type,name) DAVINCI_GLOBAL type _shadow_##name
# define DAVINCI_DECLARE_GLOBAL(type,name) DAVINCI_EXPORT type _shadow_##name
# define DAVINCI_GLOBAL_REF(name) _shadow_##name
#endif

#ifdef  __cplusplus
}
#endif
#endif
