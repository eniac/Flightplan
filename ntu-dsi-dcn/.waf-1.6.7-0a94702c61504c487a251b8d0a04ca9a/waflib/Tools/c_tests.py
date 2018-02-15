#! /usr/bin/env python
# encoding: utf-8
# WARNING! Do not edit! http://waf.googlecode.com/svn/docs/wafbook/single.html#_obtaining_the_waf_file

from waflib.Configure import conf
from waflib.TaskGen import feature,before_method
import sys
LIB_CODE='''
#ifdef _MSC_VER
#define testEXPORT __declspec(dllexport)
#else
#define testEXPORT
#endif
testEXPORT int lib_func(void) { return 9; }
'''
MAIN_CODE='''
#ifdef _MSC_VER
#define testEXPORT __declspec(dllimport)
#else
#define testEXPORT
#endif
testEXPORT int lib_func(void);
int main(void) {return !(lib_func() == 9);}
'''
def link_lib_test_fun(self):
	def write_test_file(task):
		task.outputs[0].write(task.generator.code)
	rpath=[]
	if getattr(self,'add_rpath',False):
		rpath=[self.bld.path.get_bld().abspath()]
	mode=self.mode
	m='%s %s'%(mode,mode)
	bld=self.bld
	bld(rule=write_test_file,target='test.'+mode,code=LIB_CODE)
	bld(rule=write_test_file,target='main.'+mode,code=MAIN_CODE)
	bld(features=m+'shlib',source='test.'+mode,target='test')
	bld(features=m+'program test_exec',source='main.'+mode,target='app',use='test',rpath=rpath)
def check_library(self,mode=None):
	if not mode:
		mode='c'
		if self.env.CXX:
			mode='cxx'
	self.check(compile_filename=[],features='link_lib_test',msg='Checking for libraries',mode=mode)
INLINE_CODE='''
typedef int foo_t;
static %s foo_t static_foo () {return 0; }
%s foo_t foo () {
	return 0;
}
'''
INLINE_VALUES=['inline','__inline__','__inline']
def check_inline(self,**kw):
	self.start_msg('Checking for inline')
	if not'define_name'in kw:
		kw['define_name']='INLINE_MACRO'
	if not'features'in kw:
		if self.env.CXX:
			kw['features']=['cxx']
		else:
			kw['features']=['c']
	for x in INLINE_VALUES:
		kw['fragment']=INLINE_CODE%(x,x)
		try:
			self.check(**kw)
		except self.errors.ConfigurationError:
			continue
		else:
			self.end_msg(x)
			if x!='inline':
				self.define('inline',x,quote=False)
			return x
	self.fatal('could not use inline functions')
LARGE_FRAGMENT='#include <unistd.h>\nint main() { return !(sizeof(off_t) >= 8); }\n'
def check_large_file(self,**kw):
	if not'define_name'in kw:
		kw['define_name']='HAVE_LARGEFILE'
	if not'execute'in kw:
		kw['execute']=True
	if not'features'in kw:
		if self.env.CXX:
			kw['features']=['cxx','cxxprogram']
		else:
			kw['features']=['c','cprogram']
	kw['fragment']=LARGE_FRAGMENT
	kw['msg']='Checking for large file support'
	ret=True
	try:
		if self.env.DEST_BINFMT!='pe':
			ret=self.check(**kw)
	except self.errors.ConfigurationError:
		pass
	else:
		if ret:
			return True
	kw['msg']='Checking for -D_FILE_OFFSET_BITS=64'
	kw['defines']=['_FILE_OFFSET_BITS=64']
	try:
		ret=self.check(**kw)
	except self.errors.ConfigurationError:
		pass
	else:
		self.define('_FILE_OFFSET_BITS',64)
		return ret
	self.fatal('There is no support for large files')

feature('link_lib_test')(link_lib_test_fun)
before_method('process_source')(link_lib_test_fun)
conf(check_library)
conf(check_inline)
conf(check_large_file)