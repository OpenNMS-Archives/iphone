package org.opennms.mobile.client.ui;

import org.opennms.mobile.client.dao.BeanWithId;

import com.gwtmobile.ui.client.widgets.ListItem;

public class EntityListItem<T extends BeanWithId> extends ListItem {
	private T m_entity = null;

	public EntityListItem(final T entity) {
		m_entity = entity;
		getElement().setId("Entity." + entity.getId());
	}

	public T getEntity() {
		return m_entity;
	}
}
