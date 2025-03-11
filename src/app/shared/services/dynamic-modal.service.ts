// src/app/shared/services/dynamic-modal.service.ts
import { 
  ApplicationRef, 
  ComponentFactoryResolver, 
  ComponentRef, 
  Injectable, 
  Injector, 
  Type, 
  EmbeddedViewRef
} from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class DynamicModalService {
  private modalContainerElement: HTMLElement;
  private activeModals: ComponentRef<any>[] = [];

  constructor(
    private componentFactoryResolver: ComponentFactoryResolver,
    private appRef: ApplicationRef,
    private injector: Injector
  ) {
    // Create a container for modals at the body level
    this.modalContainerElement = document.createElement('div');
    this.modalContainerElement.className = 'dynamic-modal-container';
    this.modalContainerElement.style.cssText = `
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      pointer-events: none;
      z-index: 999999;
    `;
    document.body.appendChild(this.modalContainerElement);
    console.log('Dynamic modal container created');
  }

  /**
   * Opens a component as a modal
   * @param component Component type to create
   * @param props Optional properties to pass to the component
   * @returns ComponentRef to the created component
   */
  open<T>(component: Type<T>, props?: Partial<T>): ComponentRef<T> {
    // Create component factory
    const componentFactory = this.componentFactoryResolver.resolveComponentFactory(component);
    
    // Create component
    const componentRef = componentFactory.create(this.injector);
    
    // Set component properties if provided
    if (props) {
      // Fix for TypeScript error: Cast instance to any to avoid type checking issues
      Object.keys(props).forEach(key => {
        (componentRef.instance as any)[key] = (props as any)[key];
      });
    }
    
    // Attach to the Angular component tree
    this.appRef.attachView(componentRef.hostView);
    
    // Get DOM element from component
    const domElement = (componentRef.hostView as EmbeddedViewRef<any>).rootNodes[0] as HTMLElement;
    
    // Enable pointer events for the modal
    domElement.style.pointerEvents = 'auto';
    
    // Add component to modal container
    this.modalContainerElement.appendChild(domElement);
    
    // Track this modal
    this.activeModals.push(componentRef);
    
    // Return reference for future management
    return componentRef;
  }

  /**
   * Closes a specific modal
   * @param componentRef Reference to the component to close
   */
  close<T>(componentRef: ComponentRef<T>): void {
    // Find the index of this component in our active modals
    const index = this.activeModals.indexOf(componentRef);
    if (index !== -1) {
      // Remove from our tracking array
      this.activeModals.splice(index, 1);
      
      // Detach from Angular component tree
      this.appRef.detachView(componentRef.hostView);
      
      // Destroy the component
      componentRef.destroy();
    }
  }

  /**
   * Closes all open modals
   */
  closeAll(): void {
    // Close each modal in reverse order
    for (let i = this.activeModals.length - 1; i >= 0; i--) {
      const componentRef = this.activeModals[i];
      this.appRef.detachView(componentRef.hostView);
      componentRef.destroy();
    }
    
    // Clear the tracking array
    this.activeModals = [];
  }
}