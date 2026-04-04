<script setup lang="ts">
import { ref } from 'vue';
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';

// import components
import ColorCards from '@/components/widgets/chart/ColorCards.vue';
import SmallCharts from '@/components/widgets/chart/SmallCharts.vue';
import VisitCard from '@/components/widgets/chart/VisitCard.vue';
import BounceRate from '@/components/widgets/chart/BounceRate.vue';
import ProductChart from '@/components/widgets/chart/ProductChart.vue';
import MarketShare from '@/components/widgets/chart/MarketShare.vue';
import TotalRevenue from '@/components/widgets/chart/TotalRevenue.vue';
import SalesDay from '@/components/widgets/chart/SalesDay.vue';
import OrderMonth from '@/components/widgets/chart/OrderMonth.vue';
import PageView from '@/components/widgets/chart/PageView.vue';
import CustomerSatisfaction from '@/components/widgets/chart/CustomerSatisfaction.vue';
import NewStock from '@/components/widgets/chart/NewStock.vue';

const page = ref({ title: 'Charts' });
const breadcrumbs = ref([
  {
    title: 'Widget',
    disabled: false,
    href: '#'
  },
  {
    title: 'Charts',
    disabled: true,
    href: '#'
  }
]);
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />

  <v-row>
    <v-col cols="12">
      <ColorCards />
    </v-col>
    <v-col cols="12" lg="7">
      <MarketShare />
    </v-col>
    <v-col cols="12" lg="5">
      <TotalRevenue />
    </v-col>
    <v-col cols="12">
      <SmallCharts />
    </v-col>
    <v-col cols="12" md="6" lg="4">
      <SalesDay />
    </v-col>
    <v-col cols="12" md="6" lg="4">
      <OrderMonth />
    </v-col>
    <v-col cols="12" lg="4">
      <PageView />
    </v-col>
    <v-col cols="12" sm="6" lg="4">
      <VisitCard />
    </v-col>
    <v-col cols="12" sm="6" lg="4">
      <BounceRate />
    </v-col>
    <v-col cols="12" lg="4">
      <ProductChart />
    </v-col>

    <v-col cols="12" lg="6">
      <NewStock />
    </v-col>

    <v-col cols="12" lg="6">
      <CustomerSatisfaction />
    </v-col>
  </v-row>
</template>
