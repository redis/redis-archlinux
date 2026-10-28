ifndef _REDIS_ARCH_MODULE_FLAGS_LOADED
_REDIS_ARCH_MODULE_FLAGS_LOADED := 1

# MAKEFILES reaches every recursive make; adapt only the two readies modules.
ifneq ($(filter %/modules/redisbloom/src %/modules/redistimeseries/src,$(CURDIR)),)
CC_FLAGS.common += $(CPPFLAGS)
# Retain upstream -O3 while importing distribution compiler flags.
CC_C_FLAGS.lang += $(filter-out -O%,$(CFLAGS))
CC_CXX_FLAGS.lang += $(filter-out -O%,$(CXXFLAGS))
# Bloom's custom C rule omits CC_C_FLAGS; its CMake dependencies use the buckets above.
ifneq ($(filter %/modules/redisbloom/src,$(CURDIR)),)
CC_FLAGS += $(filter-out -O%,$(CFLAGS))
endif
LD_FLAGS += $(LDFLAGS)
endif

endif
