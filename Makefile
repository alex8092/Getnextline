CC = gcc

FTDIR = $(HOME)/.ft

CFLAGS = -Wall -Werror -Wextra -I$(INCLUDEDIR) -fPIC
CFLAGS += -I$(FTDIR)/include

DEBUG = true
ifeq ($(DEBUG), true)
	CFLAGS += -ggdb3
else
	CFLAGS += -O3
endif

LDFLAGS_TEST = -L$(FTDIR)/lib -lftastr -lftcommon -Wl,-rpath,$(FTDIR)/lib

LDFLAGS = -shared $(LDFLAGS_TEST)

LD_LIBRARY_PATH=$(FTDIR)/lib:$(LD_LIBRARY_PATH)

NAME = $(LIBDIR)/$(SHORTNAME)
SHORTNAME = libftgetnextline.so

SRCS =	ft_getnextline.c \

SRCSTEST = main.c

TESTDIR = tests
LIBDIR = lib
OBJDIR = obj
SRCDIR = src
INCLUDEDIR = include/ft

RED = \033[0;31m
GREEN = \033[0;32m
NO = \033[0m

OBJS_BASE = $(SRCS:.c=.o)

OBJS_TEST = $(SRCSTEST:.c=.o)

OBJS = $(addprefix $(OBJDIR)/, $(OBJS_BASE))

OBJSTEST = $(addprefix $(OBJDIR)/, $(OBJS_TEST))

all: start 

print_begin:
	@rm -f .make_errors
	@echo "Compiling ..."

print_error:
	@if [ -e .make_errors ]; then cat .make_errors; fi
	@rm -f .make_errors

test: print_begin $(OBJS) $(OBJSTEST) print_error $(NAME)_test

start: print_begin $(OBJS) print_error $(NAME)

$(NAME)_test: $(OBJS) $(OBJSTEST)
	@$(CC) -o test.bin $^ $(LDFLAGS_TEST)

$(NAME): $(OBJS) 
	@mkdir -p $(LIBDIR)
	@$(CC) -o $@ $(OBJS) $(LDFLAGS)

install:
	@chmod +x install.sh
	@./install.sh $(NAME) $(INCLUDEDIR) $(LIBDIR)

uninstall:
	@chmod +x install.sh
	@./install.sh $(NAME) $(INCLUDEDIR) $(LIBDIR) uninstall

$(INCLUDEDIR)/getnextline_private.h: $(INCLUDEDIR)/getnextline.h
$(OBJDIR)/ft_getnextline.o: $(INCLUDEDIR)/getnextline_private.h

$(OBJDIR)/%.o: $(TESTDIR)/%.c
	@mkdir -p $(OBJDIR)
	@($(CC) -o $@ -c $< $(CFLAGS) 2>> .make_errors\
	  && echo "${GREEN}[-]${NO} Compiling \"$@\"") \
	|| echo "${RED}[x]${NO} Compiling \"$@\""


$(OBJDIR)/%.o: $(SRCDIR)/%.c
	@mkdir -p $(OBJDIR)
	@($(CC) -o $@ -c $< $(CFLAGS) 2>> .make_errors\
	  && echo "${GREEN}[-]${NO} Compiling \"$@\"") \
	|| echo "${RED}[x]${NO} Compiling \"$@\""

clean:
	@echo "Clean objects ..."
	@rm -f $(OBJS)
	@rm -rf $(OBJDIR)

fclean: clean
	@echo "Clean library ..."
	@rm -rf $(LIBDIR)
	@rm -f test.bin


re: fclean all

.PHONY: all clean fclean re
