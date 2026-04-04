<script setup lang="ts">
import { ref } from 'vue';
import BaseBreadcrumb from '@/components/shared/BaseBreadcrumb.vue';
import CardHeaderFooter from '@/components/shared/CardHeaderFooter.vue';
import WidgetCard from '@/components/shared/WidgetCard.vue';
import WidgetCardv2 from '@/components/shared/WidgetCardv2.vue';

// imports widgets
import TodoList from '@/components/widgets/data/TodoList.vue';
import TrafficSources from '@/components/widgets/data/TrafficSources.vue';
import TeamMembers from '@/components/widgets/data/TeamMembers.vue';
import UserActivity from '@/components/widgets/data/UserActivity.vue';
import LatestPosts from '@/components/widgets/data/LatestPosts.vue';
import Messages from '@/components/widgets/data/MessageList.vue';
import Projects from '@/components/widgets/data/ProjectList.vue';
import ProductSales from '@/components/widgets/data/ProductSales.vue';
import Tasks from '@/components/widgets/data/TaskList.vue';
import ApplicationSales from '@/components/widgets/data/ApplicationSales.vue';
import ActiveTickets from '@/components/widgets/data/ActiveTickets.vue';
import Feeds from '@/components/widgets/data/FeedList.vue';
import LatestCustomer from '@/components/widgets/data/LatestCustomer.vue';
import LatestOrder from '@/components/widgets/data/LatestOrder.vue';
import IncomingRequest from '@/components/widgets/data/IncomingRequest.vue';
import TotalRevenue from '@/components/widgets/data/TotalRevenue.vue';
import NewCustomers from '@/components/widgets/data/NewCustomers.vue';
import RecentTickets from '@/components/widgets/data/RecentTickets.vue';

const page = ref({ title: 'Data' });
const breadcrumbs = ref([
  {
    title: 'Widget',
    disabled: false,
    href: '#'
  },
  {
    title: 'Data',
    disabled: true,
    href: '#'
  }
]);
</script>

<template>
  <BaseBreadcrumb :title="page.title" :breadcrumbs="breadcrumbs" />

  <v-row>
    <!-- ---------------------------------------------------------------- -->
    <!-- Todo List -->
    <!-- ---------------------------------------------------------------- -->
    <v-col cols="12" lg="4">
      <CardHeaderFooter title="To Do List">
        <TodoList />
        <template #footer>
          <div class="text-end mt-2 w-100">
            <v-btn color="primary" variant="flat" icon>
              <PlusIcon stroke-width="1.5" size="24" />
            </v-btn>
          </div>
        </template>
      </CardHeaderFooter>
    </v-col>

    <!-- ---------------------------------------------------------------- -->
    <!-- Traffic Sources -->
    <!-- ---------------------------------------------------------------- -->
    <v-col cols="12" lg="4">
      <WidgetCard title="Traffic Sources">
        <TrafficSources />
      </WidgetCard>
    </v-col>

    <!-- ---------------------------------------------------------------- -->
    <!-- Team Members -->
    <!-- ---------------------------------------------------------------- -->
    <v-col cols="12" lg="4">
      <CardHeaderFooter title="Team Members">
        <TeamMembers />

        <template #footer>
          <div class="text-sm-end text-center mt-2 w-100">
            <v-btn color="primary" variant="text"> View All Projects </v-btn>
          </div>
        </template>
      </CardHeaderFooter>
    </v-col>

    <!-- ---------------------------------------------------------------- -->
    <!-- User Activity -->
    <!-- ---------------------------------------------------------------- -->
    <v-col cols="12" lg="6">
      <CardHeaderFooter title="User Activity" class="activity-card">
        <UserActivity />

        <template #footer>
          <div class="text-sm-end text-center mt-2 w-100">
            <v-btn color="primary" variant="text"> View All Projects </v-btn>
          </div>
        </template>
      </CardHeaderFooter>
    </v-col>

    <!-- ---------------------------------------------------------------- -->
    <!-- Messages -->
    <!-- ---------------------------------------------------------------- -->
    <v-col cols="12" lg="6">
      <CardHeaderFooter title="Messages">
        <Messages />

        <template #footer>
          <div class="text-sm-end text-center mt-2 w-100">
            <v-btn color="primary" variant="text"> View Friend List </v-btn>
          </div>
        </template>
      </CardHeaderFooter>
    </v-col>

    <!-- ---------------------------------------------------------------- -->
    <!-- Projects -->
    <!-- ---------------------------------------------------------------- -->
    <v-col cols="12" lg="6">
      <WidgetCardv2 title="Projects">
        <Projects />

        <template #footer>
          <div class="text-sm-end text-center mt-2 w-100">
            <v-btn color="primary" variant="text"> View All Projects </v-btn>
          </div>
        </template>
      </WidgetCardv2>
    </v-col>

    <!-- ---------------------------------------------------------------- -->
    <!-- Product Sales -->
    <!-- ---------------------------------------------------------------- -->
    <v-col cols="12" lg="6">
      <WidgetCardv2 title="Product Sales" hideaction>
        <ProductSales />
      </WidgetCardv2>
    </v-col>

    <!-- ---------------------------------------------------------------- -->
    <!-- Tasks -->
    <!-- ---------------------------------------------------------------- -->
    <v-col cols="12" lg="4">
      <WidgetCardv2 title="Tasks">
        <Tasks />
        <template #footer>
          <div class="text-sm-end text-center mt-3 w-100">
            <v-btn color="primary" variant="text"> View All Projects </v-btn>
          </div>
        </template>
      </WidgetCardv2>
    </v-col>

    <!-- ---------------------------------------------------------------- -->
    <!-- Application Sales -->
    <!-- ---------------------------------------------------------------- -->
    <v-col cols="12" lg="8">
      <WidgetCardv2 title="Application Sales">
        <ApplicationSales />
        <template #footer>
          <div class="text-sm-end text-center mt-2 w-100">
            <v-btn color="primary" variant="text"> View All Projects </v-btn>
          </div>
        </template>
      </WidgetCardv2>
    </v-col>

    <!-- ---------------------------------------------------------------- -->
    <!-- Active Tickets -->
    <!-- ---------------------------------------------------------------- -->
    <v-col cols="12" lg="8">
      <WidgetCardv2 title="Active Tickets">
        <ActiveTickets />
        <template #footer>
          <div class="text-sm-end text-center mt-2 w-100">
            <v-btn color="primary" variant="text"> View All Projects </v-btn>
          </div>
        </template>
      </WidgetCardv2>
    </v-col>

    <!-- ---------------------------------------------------------------- -->
    <!-- Latest Posts -->
    <!-- ---------------------------------------------------------------- -->
    <v-col cols="12" lg="4">
      <WidgetCardv2 title="Latest Posts">
        <LatestPosts />

        <template #footer>
          <div class="text-sm-end text-center mt-2 w-100">
            <v-btn color="primary" variant="text"> View Friend List </v-btn>
          </div>
        </template>
      </WidgetCardv2>
    </v-col>

    <!-- ---------------------------------------------------------------- -->
    <!-- Feeds -->
    <!-- ---------------------------------------------------------------- -->
    <v-col cols="12" lg="4">
      <WidgetCardv2 title="Feeds">
        <Feeds />

        <template #footer>
          <div class="text-sm-end text-center mt-2 w-100">
            <v-btn color="primary" variant="text"> View All Feeds </v-btn>
          </div>
        </template>
      </WidgetCardv2>
    </v-col>

    <!-- ---------------------------------------------------------------- -->
    <!-- Latest Customers -->
    <!-- ---------------------------------------------------------------- -->
    <v-col cols="12" lg="8">
      <WidgetCardv2 title="Latest Customers">
        <LatestCustomer />

        <template #footer>
          <div class="text-sm-end text-center mt-2 w-100">
            <v-btn color="primary" variant="text"> View All Latest Customers </v-btn>
          </div>
        </template>
      </WidgetCardv2>
    </v-col>

    <!-- ---------------------------------------------------------------- -->
    <!-- Latest Order -->
    <!-- ---------------------------------------------------------------- -->
    <v-col cols="12">
      <WidgetCardv2 title="Latest Order">
        <LatestOrder />

        <template #footer>
          <div class="text-sm-end text-center mt-2 w-100">
            <v-btn color="primary" variant="text"> View All Orders </v-btn>
          </div>
        </template>
      </WidgetCardv2>
    </v-col>

    <!-- ---------------------------------------------------------------- -->
    <!-- Incoming Requests -->
    <!-- ---------------------------------------------------------------- -->
    <v-col cols="12" lg="4">
      <WidgetCardv2 title="Incoming Requests">
        <IncomingRequest />

        <template #footer>
          <div class="text-sm-end text-center mt-2 w-100">
            <v-btn color="primary" variant="text"> Show More </v-btn>
          </div>
        </template>
      </WidgetCardv2>
    </v-col>

    <!-- ---------------------------------------------------------------- -->
    <!-- Total Revenue -->
    <!-- ---------------------------------------------------------------- -->
    <v-col cols="12" lg="4">
      <WidgetCardv2 title="Total Revenue" hideaction>
        <TotalRevenue />
      </WidgetCardv2>
    </v-col>

    <!-- ---------------------------------------------------------------- -->
    <!-- New Customers -->
    <!-- ---------------------------------------------------------------- -->
    <v-col cols="12" lg="4">
      <WidgetCardv2 title="New Customers" hideaction>
        <NewCustomers />
      </WidgetCardv2>
    </v-col>

    <!-- ---------------------------------------------------------------- -->
    <!-- Recent Tickets -->
    <!-- ---------------------------------------------------------------- -->
    <v-col cols="12">
      <WidgetCardv2 title="Recent Tickets">
        <RecentTickets />
        <template #footer>
          <div class="text-sm-end text-center mt-2 w-100">
            <v-btn color="primary" variant="text"> View All Tickets </v-btn>
          </div>
        </template>
      </WidgetCardv2>
    </v-col>
  </v-row>
</template>

<style lang="scss">
.activity-card {
  .v-card-text {
    padding: 0;
  }
}
</style>
