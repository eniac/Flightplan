'''
Defines decorators used to memoize the results of function calls to files

Use
@memoize_to_folder("directory_name")
def my_expensive_function(arg1, arg2):
    ...
    return ...

Calling my_expensive_function('1', 5)
will attempt to load the results from a file if it exists.

Calling my_expensive_function('1', 5, __recalculate=True)
will always recalculate and store the results in a file
'''
import pickle
import os
import re

def strarg(arg):
    try:
        return re.sub("[^A-Za-z0-9_]", "", arg.__name__)
    except Exception:
        starg = str(arg)
        if starg[0] == '<' and starg[-1] == '>':
            try:
                starg = hash(starg)
            except:
                pass
        return re.sub("[^A-Za-z0-9_]", "", starg)

def memoize_to_file(fn, dir = ''):
    '''
    A decorator function to memoize the outputs of a function to pickle files
    '''
    if len(dir) > 0:
        try:
            os.makedirs(dir)
        except Exception as e:
            pass


    def wrapper(*args, **kwargs):
        '''
        The inner function returned by memoize_to_file.
        Serializes arguments for the filename, then writes or reads
        this function's output to that filename.
        Accepts additional __recalculate keywork argument which allows
        it to ignore previous memoization.
        Attempts to call arg.__name__ on arguments, in case they are function objects.
        '''

        __recalculate = kwargs.get('__recalculate', False)
        try:
            del kwargs['__recalculate']
        except KeyError:
            pass

        fname = os.path.join(dir, fn.__name__)
        for argname, arg in zip(fn.__code__.co_varnames, args):
            fname += '__'+argname + '-' + strarg(arg)

        for argname, arg in kwargs.items():
            fname += '__'+argname + '-' + strarg(arg)

        fname += '.pickle'

        if __recalculate:
            rtn = fn(*args, **kwargs)
            with open(fname, 'wb') as f:
                pickle.dump(rtn, f)

            return rtn

        try:
            with open(fname, 'rb') as f:
                print("Loading from {}".format(fname))
                rtn = pickle.load(f)
        except Exception:
            rtn = fn(*args, **kwargs)
            with open(fname, 'wb') as f:
                pickle.dump(rtn, f)

        return rtn

    return wrapper

def memoize_to_folder(dir):
    ''' Wrapper function for memoize_to_file so you can decorate a function with:
    @memoize_to_folder(D)
    and all created pickle files will be written to files in the directory D'''
    return lambda fn: memoize_to_file(fn, dir)
