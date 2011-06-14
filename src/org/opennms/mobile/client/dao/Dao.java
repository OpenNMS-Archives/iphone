package org.opennms.mobile.client.dao;

import java.util.Map;

import org.opennms.mobile.client.ui.DaoUpdateCallback;

public interface Dao<T extends BeanWithId> {

//	public T get(int id);
//	public Collection<T> findAll();
//	public Collection<T> findAll(Map<String,String> parameters);
	public void findAll(Map<String, String> parameters, DaoUpdateCallback<T> callback);

	public void save(T obj);

	public Class<? extends T> getClassType();
}
