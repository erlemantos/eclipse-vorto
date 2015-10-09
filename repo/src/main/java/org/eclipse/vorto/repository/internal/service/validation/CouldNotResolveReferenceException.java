package org.eclipse.vorto.repository.internal.service.validation;

import java.util.Collection;
import java.util.Collections;

import org.eclipse.vorto.repository.model.ModelId;
import org.eclipse.vorto.repository.model.ModelResource;
import org.eclipse.vorto.repository.validation.ValidationException;

public class CouldNotResolveReferenceException extends ValidationException {

	private static final long serialVersionUID = 6871069157875387299L;
	private Collection<ModelId> unresolvedReferences = Collections.emptyList();
	
	public CouldNotResolveReferenceException(String msg, ModelResource modelResource, Collection<ModelId> unresolvedReferences) {
		super(msg, modelResource);
		this.unresolvedReferences = unresolvedReferences;
	}

	public Collection<ModelId> getUnresolvedReferences() {
		return unresolvedReferences;
	}

	public void setUnresolvedReferences(Collection<ModelId> unresolvedReferences) {
		this.unresolvedReferences = unresolvedReferences;
	}
}
