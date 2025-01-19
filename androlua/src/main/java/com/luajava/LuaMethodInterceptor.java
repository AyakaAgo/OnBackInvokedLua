package com.luajava;

import android.support.annotation.NonNull;

import com.android.cglib.proxy.MethodInterceptor;
import com.android.cglib.proxy.MethodProxy;
import com.androlua.LuaContext;

import java.lang.reflect.Method;

/**
 * Created by nirenr on 2019/3/1.
 */

public class LuaMethodInterceptor implements MethodInterceptor {
    private final LuaContext mContext;
    private LuaObject obj;

    public LuaMethodInterceptor(LuaObject obj) {
        this.obj = obj;
        mContext = obj.getLuaState().getContext();
    }

    @Override
    public Object intercept(Object object, final @NonNull Object[] args, MethodProxy methodProxy) throws Exception {
        synchronized (obj.L) {
            Method method = methodProxy.getOriginalMethod();
            String methodName = method.getName();
            LuaObject func;
            if (obj.isFunction()) {
                func = obj;
            } else {
                func = obj.getField(methodName);
            }
            Class<?> retType = method.getReturnType();

            if (func.isNil()) {
                /*if (args.length == 0) {
                    if (methodName.equals("hashCode")) {
                        return object.hashCode();
                    } else if (methodName.equals("toString")) {
                        return object.toString();
                    }
                } else if (methodName.equals("equals") && args.length == 1) {
                    return args[0].equals(object);
                }*/

                if (retType.equals(boolean.class) || retType.equals(Boolean.class))
                    return false;
                else if (retType.isPrimitive() || Number.class.isAssignableFrom(retType))
                    return 0;
                else
                    return null;
            }
            Object[] na = new Object[args.length + 1];
            System.arraycopy(args,0,na,1,args.length);
            na[0]=new SuperCall(object,methodProxy);
            Object ret = null;
            try {
                // Checks if returned type is void. if it is returns null.
                if (retType.equals(Void.class) || retType.equals(void.class)) {
                    func.call(na);
                    ret = null;
                } else {
                    ret = func.call(na);
                    if (ret instanceof Double) {
                        ret = LuaState.convertLuaNumber((Double) ret, retType);
                    }
                }
            } catch (LuaException e) {
                mContext.sendError(methodName, e);
            }
            if (ret == null) {
                /*if (args.length == 0) {
                    if (methodName.equals("hashCode")) {
                        return object.hashCode();
                    } else if (methodName.equals("toString")) {
                        return object.toString();
                    }
                } else if (methodName.equals("equals") && args.length == 1) {
                    return args[0].equals(object);
                }*/

                if (retType.equals(boolean.class) || retType.equals(Boolean.class))
                    return false;
                else if (retType.isPrimitive() || Number.class.isAssignableFrom(retType))
                    return 0;
            }
            return ret;
        }
    }

    private class SuperCall implements LuaMetaTable{

        private final Object mObject;
        private final MethodProxy mMethodProxy;

        public SuperCall(Object obj, MethodProxy methodProxy){
            mObject =obj;
            mMethodProxy=methodProxy;
        }

        @Override
        public Object __call(Object... arg) throws LuaException {
            return mMethodProxy.invokeSuper(mObject,arg);
        }

        @Override
        public Object __index(String key) {
            return null;
        }

        @Override
        public void __newIndex(String key, Object value) {

        }
    }
}
