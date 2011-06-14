package org.opennms.mobile.client.dao;

import java.util.Collection;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

import org.opennms.mobile.client.model.Server;
import org.opennms.mobile.client.ui.DaoUpdateCallback;

public abstract class AbstractDao<T extends BeanWithId> implements Dao<T> {
	/** Retrieve a list of objects associated with the server **/
	protected abstract Set<T> getObjects(final Server server);

	/** Retrieve the object with the given ID. **/
	/*
	public T get(int id) {
		for (final T obj : getObjects(DaoFactory.getInstance().getCurrentServer())) {
			if (obj.getId() == id) {
				return obj;
			}
		}
		return null;
	}

	public Collection<T> findAll(final Map<String,String> parameters) {
		final int limit = AbstractDao.getLimit(parameters);
		
		if (limit == 0) {
			return findAll();
		} else {
			int count = 0;
			
			final Set<T> objects = getObjects(DaoFactory.getInstance().getCurrentServer());
			if (objects.size() <= limit) {
				return objects;
			}
			final Set<T> retObjs = new LinkedHashSet<T>();
			for (final T obj : objects) {
				if (count++ == limit) {
					break;
				}
				retObjs.add(obj);
			}
			return retObjs;
		}
	}

	public Collection<T> findAll() {
		return getObjects(DaoFactory.getInstance().getCurrentServer());
	}
	*/

	public void findAll(final Map<String,String> parameters, final DaoUpdateCallback<T> callback) {
		callback.update(filter(parameters, getObjects(DaoFactory.getInstance().getCurrentServer())));
	}

	public void save(final T obj) {
		getObjects(DaoFactory.getInstance().getCurrentServer()).add(obj);
	}

	public static int getLimit(final Map<String, String> parameters) {
		if (parameters != null && parameters.containsKey("limit")) {
			return Integer.valueOf(parameters.get("limit"));
		}
		return 0;
	}
	
	protected Collection<T> filter(final Map<String, String> parameters, final Collection<T> items) {
		final int limit = AbstractDao.getLimit(parameters);
		
		if (limit == 0) {
			return items;
		}
		
		int count = 0;
		final Set<T> retItems = new LinkedHashSet<T>();
		for (final T server : items) {
			if (count++ == limit) {
				break;
			}
			retItems.add(server);
		}

		return retItems;
	}

}
