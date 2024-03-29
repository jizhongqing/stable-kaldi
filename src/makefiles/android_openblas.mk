ifndef FSTROOT
$(error FSTROOT not defined.)
endif

ifndef OPENFSTLIBS
$(error OPENFSTLIBS not defined.)
endif

ifndef TOOLCHAIN_INCLUDE
$(error TOOLCHAIN_INCLUDE not defined.)
endif

ifndef OPENBLASLIBS
$(error OPENBLASLIBS not defined.)
endif

ifndef OPENBLASROOT
$(error OPENBLASROOT not defined.)
endif

 CXXFLAGS += -mhard-float -D_NDK_MATH_NO_SOFTFP=1  -I$(TOOLCHAIN_INCLUDE) -Wall -I.. \
      -pthread \
	  -DHAVE_OPENBLAS -I $(OPENBLASROOT)/include \
      -DKALDI_DOUBLEPRECISION=0 -DHAVE_POSIX_MEMALIGN \
      -Wno-sign-compare -Winit-self \
       -DHAVE_CXXABI_H \
      -DHAVE_CLAPACK \
      -I$(FSTROOT)/include \
      $(EXTRA_CXXFLAGS) -O2\
      # -O0 -DKALDI_PARANOID

ifeq ($(KALDI_FLAVOR), dynamic)
CXXFLAGS += -fPIC
endif

LDFLAGS = -Wl,--no-warn-mismatch -pie
LDLIBS = $(EXTRA_LDLIBS) $(OPENFSTLIBS) $(OPENBLASLIBS) -ldl -lm_hard

# Add no-mismatched-tags flag to suppress the annoying clang warnings
# that are perfectly valid per spec.
COMPILER = $(shell $(CXX) -v 2>&1 )
ifeq ($(findstring clang,$(COMPILER)),clang)
  CXXFLAGS += -Wno-mismatched-tags
  # Link with libstdc++ if we are building against OpenFst < 1.4
  ifneq ("$(OPENFST_GE_10400)","1")
    CXXFLAGS += -stdlib=libstdc++
    LDFLAGS += -stdlib=libstdc++
  endif
endif

# We need to tell recent versions of g++ to allow vector conversions without
# an explicit cast provided the vectors are of the same size.
ifeq ($(findstring GCC,$(COMPILER)),GCC)
	CXXFLAGS += -flax-vector-conversions -Wno-unused-local-typedefs
endif
