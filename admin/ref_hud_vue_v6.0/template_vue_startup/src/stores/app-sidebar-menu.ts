import { defineStore } from "pinia";

export const useAppSidebarMenuStore = defineStore("appSidebarMenu", () => {
	return [{
		'text': 'Navigation',
		'is_header': true
	},{
		'url': '/',
		'icon': 'bi bi-house-door',
		'text': 'Home'
	}]
});