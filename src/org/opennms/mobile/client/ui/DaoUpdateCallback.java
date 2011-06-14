package org.opennms.mobile.client.ui;

import java.util.Collection;

public interface DaoUpdateCallback<T> {
	public void update(Collection<T> items);
}
