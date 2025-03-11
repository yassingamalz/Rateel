// src/app/shared/services/modal-portal.service.ts
import { ApplicationRef, ComponentFactoryResolver, ComponentRef, EmbeddedViewRef, Injectable, Injector, Type } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class ModalPortalService {
  private modalHost: HTMLElement | null = null;

  constructor(
    private componentFactoryResolver: ComponentFactoryResolver,
    private appRef: ApplicationRef,
    private injector: Injector
  ) {
    this.setupModalHost();
  }

  /**
   * Creates a host element for modals at the body level
   */
  private setupModalHost(): void {
    // Create modal host container if it doesn't exist
    if (!this.modalHost) {
      this.modalHost = document.createElement('div');
      this.modalHost.className = 'modal-portal-host';
      this.modalHost.style.cssText = `
        position: fixed;
        pointer-events: none;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        z-index: 999999;
      `;
      document.body.appendChild(this.modalHost);
      console.log('Modal portal host created');
    }
  }

  /**
   * Creates and attaches a component to the modal host
   * @param component The component to create
   * @param data Optional data to pass to the component
   * @returns A reference to the created component
   */
  createComponent<T>(component: Type<T>, data?: any): ComponentRef<T> {
    // Make sure the modal host exists
    this.setupModalHost();

    // Create component
    const componentFactory = this.componentFactoryResolver.resolveComponentFactory(component);
    const componentRef = componentFactory.create(this.injector);

    // Pass data to component if provided
    if (data) {
      Object.assign(componentRef.instance, data);
    }

    // Attach component to application
    this.appRef.attachView(componentRef.hostView);

    // Get DOM element from component
    const domElement = (componentRef.hostView as EmbeddedViewRef<any>).rootNodes[0] as HTMLElement;

    // Add component to modal host
    this.modalHost!.appendChild(domElement);

    // Return component reference for future use (like detaching)
    return componentRef;
  }

  /**
   * Removes a component from the modal host
   * @param componentRef The component reference to remove
   */
  removeComponent<T>(componentRef: ComponentRef<T>): void {
    this.appRef.detachView(componentRef.hostView);
    componentRef.destroy();
  }
  
  /**
   * Clean up the modal host on application destroy
   */
  destroyHost(): void {
    if (this.modalHost && document.body.contains(this.modalHost)) {
      document.body.removeChild(this.modalHost);
      this.modalHost = null;
    }
  }
}