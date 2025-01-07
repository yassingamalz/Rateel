import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { UnitCardComponent } from './features/units/components/unit-card/unit-card.component';
import { UnitListComponent } from './features/units/components/unit-list/unit-list.component';
import { UnitHeaderComponent } from './features/units/components/unit-header/unit-header.component';
import { CommonModule } from '@angular/common';
import { LayoutModule } from './layout/layout.module';
import { FontAwesomeModule } from '@fortawesome/angular-fontawesome';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { HttpClientModule } from '@angular/common/http';

@NgModule({
  declarations: [
    AppComponent,
    UnitCardComponent,
    UnitListComponent,
    UnitHeaderComponent,
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    LayoutModule,
    CommonModule,
    FontAwesomeModule,
    BrowserAnimationsModule,
    HttpClientModule,
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
