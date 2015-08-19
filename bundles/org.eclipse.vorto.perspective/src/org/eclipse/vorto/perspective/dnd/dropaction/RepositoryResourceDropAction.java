/*******************************************************************************
 *  Copyright (c) 2015 Bosch Software Innovations GmbH and others.
 *  All rights reserved. This program and the accompanying materials
 *  are made available under the terms of the Eclipse Public License v1.0
 *  and Eclipse Distribution License v1.0 which accompany this distribution.
 *   
 *  The Eclipse Public License is available at
 *  http://www.eclipse.org/legal/epl-v10.html
 *  The Eclipse Distribution License is available at
 *  http://www.eclipse.org/org/documents/edl-v10.php.
 *   
 *  Contributors:
 *  Bosch Software Innovations GmbH - Please refer to git log
 *******************************************************************************/
package org.eclipse.vorto.perspective.dnd.dropaction;

import java.io.ByteArrayInputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.vorto.codegen.ui.display.MessageDisplayFactory;
import org.eclipse.vorto.core.api.model.model.Model;
import org.eclipse.vorto.core.api.model.model.ModelFactory;
import org.eclipse.vorto.core.api.model.model.ModelReference;
import org.eclipse.vorto.core.api.repository.IModelRepository;
import org.eclipse.vorto.core.api.repository.ModelRepositoryFactory;
import org.eclipse.vorto.core.api.repository.ModelResource;
import org.eclipse.vorto.core.model.IModelProject;
import org.eclipse.vorto.core.model.ModelId;
import org.eclipse.vorto.core.model.ModelType;
import org.eclipse.vorto.core.service.IModelProjectService;
import org.eclipse.vorto.core.service.ModelProjectServiceFactory;
import org.eclipse.vorto.perspective.dnd.IDropAction;
import org.eclipse.vorto.perspective.function.ModelToDslFunction;

import com.google.common.base.Function;

/**
 * A drop action for dropping a Model Resource from Repository view to an
 * IModelProject
 *
 */
public class RepositoryResourceDropAction implements IDropAction {

	private static final String INFOMODEL_EXT = ".infomodel";

	private static final String FBMODEL_EXT = ".fbmodel";

	private static final String TYPE_EXT = ".type";

	private static final String SHARED_MODELS_DIR = "src/shared_models/";

	private static final String SHARED_MODEL_IS_PROJ_ERROR = "Cannot copy shared model %s to %s, a local project already exist for shared model.";

	private static final String SAVING = "Saving model to %s";

	private IModelRepository modelRepo = ModelRepositoryFactory.getModelRepository();

	private IModelProjectService projectService = ModelProjectServiceFactory.getDefault();

	private Function<Model, String> modelToDsl = new ModelToDslFunction();

	private Map<ModelType, String> modelFileExtensionMap = initializeExtensionMap();

	@Override
	public boolean performDrop(IModelProject receivingProject, Object droppedObject) {
		Objects.requireNonNull(receivingProject, "receivingProject shouldn't be null.");
		Objects.requireNonNull(droppedObject, "droppedObject shouldn't be null.");

		ModelResource modelResource = (ModelResource) droppedObject;

		Model droppedObjectModel = downloadAndSaveModel(receivingProject.getProject(), modelResource.getId());

		if (droppedObjectModel != null) {
			// Add the dropped model to the receiving project's model
			addReferenceToModel(receivingProject.getModel(), droppedObjectModel);
			ModelProjectServiceFactory.getDefault().save(receivingProject);
		}

		return true;
	}

	private void addReferenceToModel(Model targetModel, Model modelToBeAdded) {
		ModelReference referenceToAdd = toModelReference(modelToBeAdded);
		for (ModelReference modelReference : targetModel.getReferences()) {
			if (EcoreUtil.equals(modelReference, referenceToAdd)) {
				return; // model reference already exists
			}
		}
		targetModel.getReferences().add(referenceToAdd);
		targetModel.eResource().getContents().add(modelToBeAdded);
	}

	// Download and save model from repository to local project.
	// It also recursively do the same for the model references.
	private Model downloadAndSaveModel(IProject project, ModelId modelId) {
		// Check if we have a local project with that same modelId
		if (projectService.getProjectByModelId(modelId) == null) {
			MessageDisplayFactory.getMessageDisplay().display("Downloading " + modelId.toString());

			Model model = modelRepo.getModel(modelId);
			if (model != null) {
				// Download references also
				for (ModelReference reference : model.getReferences()) {
					downloadAndSaveModel(project, toModelId(reference, modelId.getModelType()));
				}

				saveToProject(project, modelToDsl.apply(model), getFileName(model, modelId.getModelType()));
			} else {
				MessageDisplayFactory.getMessageDisplay().displayError(
						"Model " + modelId.toString() + " not found in repository.");
			}

			return model;
		} else {
			MessageDisplayFactory.getMessageDisplay().displayError(
					String.format(SHARED_MODEL_IS_PROJ_ERROR, modelId.toString(), project.getName()));
			return null;
		}
	}

	private ModelId toModelId(ModelReference reference, ModelType parentType) {
		String importedNamespace = reference.getImportedNamespace();
		int lastIndex = importedNamespace.lastIndexOf('.');
		if (lastIndex > 0) {
			String namespace = importedNamespace.substring(0, lastIndex);
			String name = importedNamespace.substring(lastIndex + 1, importedNamespace.length());
			ModelType modelType = ModelType.DATATYPE;
			if (parentType == ModelType.INFORMATIONMODEL) {
				modelType = ModelType.FUNCTIONBLOCK;
			}
			return new ModelId(modelType, name, namespace, reference.getVersion());
		}

		throw new RuntimeException("Malformed imported namespace = " + importedNamespace);
	}

	private void saveToProject(IProject project, String fileAsString, String fileName) {
		assert (project != null);
		assert (fileAsString != null);
		assert (fileName != null);
		try {
			IFolder folder = project.getFolder(SHARED_MODELS_DIR);
			if (!folder.exists()) {
				folder.create(IResource.NONE, true, null);
			}

			IFile file = folder.getFile(fileName);
			if (file.exists()) {
				file.delete(true, new NullProgressMonitor());
			}

			MessageDisplayFactory.getMessageDisplay().display(String.format(SAVING, file.getFullPath().toString()));
			file.create(new ByteArrayInputStream(fileAsString.getBytes()), true, new NullProgressMonitor());
		} catch (CoreException e) {
			MessageDisplayFactory.getMessageDisplay().displayError(e);
		}
	}

	private ModelReference toModelReference(Model model) {
		ModelReference reference = ModelFactory.eINSTANCE.createModelReference();
		reference.setVersion(model.getVersion());
		reference.setImportedNamespace(model.getNamespace() + "." + model.getName());

		return reference;
	}

	private String getFileName(Model model, ModelType modelType) {
		return model.getName() + modelFileExtensionMap.get(modelType);
	}

	private Map<ModelType, String> initializeExtensionMap() {
		Map<ModelType, String> extensionMap = new HashMap<ModelType, String>();
		extensionMap.put(ModelType.DATATYPE, TYPE_EXT);
		extensionMap.put(ModelType.FUNCTIONBLOCK, FBMODEL_EXT);
		extensionMap.put(ModelType.INFORMATIONMODEL, INFOMODEL_EXT);
		return extensionMap;
	}
}