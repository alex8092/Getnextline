#include "getnextline_private.h"
#include <ft/common.h>
#include <stdlib.h>

static t_fd		*ft_get_fd(t_nexl *nl, int const fd)
{
	t_fd	*cur;

	cur = nl->begin;
	while (cur)
	{
		if (cur->fd == fd)
			return (cur);
		cur = cur->next;
	}
	cur = (t_fd *)ft_memalloc(sizeof(t_fd));
	cur->next = nl->begin;
	cur->fd = fd;
	cur->tab = ft_astr_create(0);
	nl->begin = cur;
	return (cur);
}

static t_bool	ft_get_line2(t_nexl *nl, t_fd *fd, char **line)
{
	char	*str;
	char	*find;

	if (fd->tab && fd->tab->m_size)
	{
		str = fd->tab->get(fd->tab, fd->tab->m_size - 1);
		if ((find = ft_strchr(str, '\n')))
		{
			str = fd->tab->erase(fd->tab, fd->tab->m_size - 1);
			*find = 0;
			fd->tab->add(fd->tab, ft_strndup(str, find - str));
			nl->save = fd->tab->joinall(fd->tab);
			(*line) = nl->save;
			fd->tab->clear(fd->tab, true);
			fd->tab->add(fd->tab, find + 1);
			if (!fd->save)
				fd->save = str;
			return (true);
		}
		str = ft_strdup(fd->tab->erase(fd->tab, fd->tab->m_size - 1));
		fd->tab->add(fd->tab, str);
	}
	return (false);
}

static t_bool	ft_get_line(t_nexl *nl, t_fd *fd, char **line)
{	
	char*	find;

	find = ft_strchr(nl->buff, '\n');
	if (find)
	{
		*find = 0;
		fd->tab->add(fd->tab, ft_strndup(nl->buff, find - nl->buff));
		nl->save = fd->tab->joinall(fd->tab);
		(*line) = nl->save;
		fd->tab->clear(fd->tab, true);
		fd->tab->add(fd->tab, ft_strdup(find + 1));
		return (true);
	}
	else
		fd->tab->add(fd->tab, ft_strdup(nl->buff));
	return (false);
}

static int		ft_final(t_nexl **nl, t_fd *fd, char **line, ssize_t ret)
{
	t_fd	*current;

	if (ret == 0 && fd && fd->tab && fd->tab->m_size)
	{
		(*nl)->save = fd->tab->joinall(fd->tab);
		if (ft_strlen((*nl)->save) > 0)
			return ((((*line) = (*nl)->save)) ? 1 : 1);
		fd->tab->free(&fd->tab, true);
		ft_strdel(&(*nl)->save);
	}
	current = (*nl)->begin;
	while (current != fd && current->next != fd)
		current = current->next;
	if (current == fd)
		(*nl)->begin = current->next;
	else
		current->next = current->next->next;
	free(fd);
	if (!(*nl)->begin)
	{
		free((*nl)->buff);
		ft_memdel((void **)nl);
	}
	return (ret);
}

int				get_next_line(int const fd, char **line)
{
	static t_nexl	*nl;
	t_fd			*cur;

	if (!nl)
	{
		nl = (t_nexl *)ft_memalloc(sizeof(t_nexl));
		nl->buff = (char *)malloc(sizeof(char) * (BUFF_SIZE + 1));
	}
	cur = ft_get_fd(nl, fd);
	if (ft_get_line2(nl, cur, line))
		return (1);
	ft_strdel(&cur->save);
	while ((nl->ret = read(fd, nl->buff, BUFF_SIZE)) > 0)
	{
		nl->buff[nl->ret] = 0;
		if (ft_get_line(nl, cur, line))
			return (1);
	}
	return (ft_final(&nl, cur, line, nl->ret));
}
