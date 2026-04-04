<script setup lang="ts">
// imported widget cards
import WidgetCardv2 from '@/components/shared/WidgetCardv2.vue';

// imported components
import MarketShare from '@/components/widgets/chart/MarketShare.vue';
import TotalRevenue from '@/components/widgets/data/TotalRevenue.vue';
import LatestCustomer from '@/components/widgets/data/LatestCustomer.vue';
import SideIconCards from '@/components/dashboard/analytics/SideIconCards.vue';
import RevenueCards from '@/components/dashboard/analytics/RevenueCards.vue';
</script>

<template>
  <v-row>
    <!-- column 1 -->
    <v-col cols="12" lg="8">
      <v-row>
        <v-col cols="12">
          <!-- -------------------------------------------------------------------- -->
          <!-- Market Share -->
          <!-- -------------------------------------------------------------------- -->
          <MarketShare />
        </v-col>
        <v-col cols="12">
          <!-- -------------------------------------------------------------------- -->
          <!-- Revenue Cards -->
          <!-- -------------------------------------------------------------------- -->
          <RevenueCards />
        </v-col>
        <v-col cols="12">
          <!-- -------------------------------------------------------------------- -->
          <!-- Latest Customers -->
          <!-- -------------------------------------------------------------------- -->
          <WidgetCardv2 title="Latest Customers">
            <LatestCustomer />

            <template #footer>
              <div class="text-end mt-2 w-100">
                <v-btn color="primary" variant="text"> View All Latest Customers </v-btn>
              </div>
            </template>
          </WidgetCardv2>
        </v-col>
      </v-row>
    </v-col>
    <!-- column 2 -->
    <v-col cols="12" lg="4">
      <v-row>
        <v-col cols="12">
          <!-- -------------------------------------------------------------------- -->
          <!-- Shares -->
          <!-- -------------------------------------------------------------------- -->
          <v-card elevation="0" class="overflow-hidden">
            <v-card variant="outlined">
              <v-row gap="0">
                <v-col cols="6" sm="6" class="pa-6 border-blue-right">
                  <v-card-text class="pa-0">
                    <div class="d-flex align-center">
                      <v-btn class="text-primary" color="lightprimary" icon variant="flat">
                        <ShareIcon stroke-width="1.5" size="24" />
                      </v-btn>

                      <div class="ms-md-6 ms-3 text-center">
                        <h5 class="mt-1">1000</h5>
                        <span class="text-medium-emphasis text-body-small text-uppercase">Shares</span>
                      </div>
                    </div>
                  </v-card-text>
                </v-col>
                <v-col cols="6" sm="6" class="pa-6">
                  <v-card-text class="pa-0">
                    <div class="d-flex align-center">
                      <v-btn class="text-primary" color="lightprimary" icon variant="flat">
                        <RouterIcon stroke-width="1.5" size="24" />
                      </v-btn>

                      <div class="ms-md-6 ms-3 text-center">
                        <h5 class="mt-1">600</h5>
                        <span class="text-medium-emphasis text-body-small text-uppercase">NETWORK</span>
                      </div>
                    </div>
                  </v-card-text>
                </v-col>

                <v-divider />
                <v-col cols="6" sm="6" class="pa-6 border-blue-right">
                  <v-card-text class="pa-0">
                    <div class="d-flex align-center">
                      <v-btn class="text-primary" color="lightprimary" icon variant="flat">
                        <FlowerIcon stroke-width="1.5" size="24" />
                      </v-btn>

                      <div class="ms-md-6 ms-3 text-center">
                        <h5 class="mt-1">3550</h5>
                        <span class="text-medium-emphasis text-body-small text-uppercase">RETURNS</span>
                      </div>
                    </div>
                  </v-card-text>
                </v-col>
                <v-col cols="6" sm="6" class="pa-6">
                  <v-card-text class="pa-0">
                    <div class="d-flex align-center">
                      <v-btn class="text-primary" color="lightprimary" icon variant="flat">
                        <BasketIcon stroke-width="1.5" size="24" />
                      </v-btn>

                      <div class="ms-md-6 ms-3 text-center">
                        <h5 class="mt-1">100%</h5>
                        <span class="text-medium-emphasis text-body-small text-uppercase">Order</span>
                      </div>
                    </div>
                  </v-card-text>
                </v-col>
              </v-row>
            </v-card>
          </v-card>
        </v-col>
        <v-col cols="12">
          <!-- -------------------------------------------------------------------- -->
          <!-- Total Revenue -->
          <!-- -------------------------------------------------------------------- -->
          <WidgetCardv2 title="Total Revenue" hideaction>
            <TotalRevenue />
          </WidgetCardv2>
        </v-col>
        <v-col cols="12">
          <SideIconCards />
        </v-col>
      </v-row>
    </v-col>
  </v-row>
</template>
