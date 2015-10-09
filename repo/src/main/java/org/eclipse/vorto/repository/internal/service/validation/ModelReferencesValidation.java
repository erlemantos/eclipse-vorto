/*******************************************************************************
 * Copyright (c) 2015 Bosch Software Innovations GmbH and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * and Eclipse Distribution License v1.0 which accompany this distribution.
 *   
 * The Eclipse Public License is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * The Eclipse Distribution License is available at
 * http://www.eclipse.org/org/documents/edl-v10.php.
 *   
 * Contributors:
 * Bosch Software Innovations GmbH - Please refer to git log
 *******************************************************************************/
package org.eclipse.vorto.repository.internal.service.validation;

import java.util.ArrayList;
import java.util.Collection;

import org.eclipse.vorto.repository.model.ModelId;
import org.eclipse.vorto.repository.model.ModelResource;
import org.eclipse.vorto.repository.service.IModelRepository;
import org.eclipse.vorto.repository.validation.IModelValidator;
import org.eclipse.vorto.repository.validation.ValidationException;

import com.google.common.base.Joiner;

public class ModelReferencesValidation implements IModelValidator {

	private IModelRepository modelRepository;

	public ModelReferencesValidation(IModelRepository modelRepository) {
		this.modelRepository = modelRepository;
	}

	@Override
	public void validate(ModelResource modelResource) throws ValidationException {
		Collection<ModelId> unresolvedReferences = new ArrayList<ModelId>();
		if (!modelResource.getReferences().isEmpty()) {
			checkReferencesRecursive(modelResource, unresolvedReferences);
		}

		if (unresolvedReferences.size() > 0) {
			throw new CouldNotResolveReferenceException(createErrorMessage(modelResource, unresolvedReferences),
					modelResource, unresolvedReferences);
		}
	}

	private void checkReferencesRecursive(ModelResource modelResource, Collection<ModelId> unresolvedReferences) {
		for (ModelId modelId : modelResource.getReferences()) {
			ModelResource reference = modelRepository.getById(modelId);
			if (reference == null) {
				unresolvedReferences.add(modelId);
			} else {	
				checkReferencesRecursive(reference, unresolvedReferences);
			}
		}
	}

	private static String createErrorMessage(ModelResource resource, Collection<ModelId> faultyReferences) {
		return "Some reference(s) cannot be resolved";
	}

}
