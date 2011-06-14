package org.opennms.mobile.client.util;

import static com.google.gwt.i18n.client.DateTimeFormat.PredefinedFormat.ISO_8601;

import java.util.Date;

import name.pehl.piriti.converter.client.DateConverter;

import com.google.gwt.i18n.client.DateTimeFormat;
import com.google.gwt.i18n.client.DateTimeFormat.PredefinedFormat;

public class LaxDateConverter extends DateConverter {
	
	@Override
    protected Date convertDate(final String value, final String format) {
		Date returnDate = null;
		if (format != null) {
			final DateTimeFormat dtFormat = DateTimeFormat.getFormat(format);
			returnDate = tryConvert(value, dtFormat);
			if (returnDate != null) return returnDate;
		}

		returnDate = tryConvert(value, DateTimeFormat.getFormat("yyyy-MM-dd'T'hh:mm:ssZ"));
		if (returnDate != null) return returnDate;

		returnDate = tryConvert(value, DateTimeFormat.getFormat(PredefinedFormat.DATE_TIME_FULL));
		if (returnDate != null) return returnDate;

		returnDate = tryConvert(value, DateTimeFormat.getFormat("EEEEE, d MMMMM yyyy k:mm:ss 'o''clock' z"));
		if (returnDate != null) return returnDate;

		returnDate = tryConvert(value, DateTimeFormat.getFormat(ISO_8601));
		return returnDate;
    }

	private Date tryConvert(final String value, final DateTimeFormat format) {
		try {
			return format.parse(value);
		} catch (final IllegalArgumentException e) {
			return null;
		}
	}
}
