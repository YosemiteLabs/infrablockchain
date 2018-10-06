/**
 *  @file
 *  @copyright defined in yosemite-public-blockchain/LICENSE
 */
#pragma once

#include <eosiolib/eosio.hpp>
#include <eosiolib/asset.hpp>
#include <yosemitelib/yx_asset.hpp>
#include <string>

namespace yosemite {
   using std::string;
   typedef uint128_t uuid;
   typedef uint64_t id_type;
   typedef string uri_type;
   using namespace eosio;

   class nft : public contract {
   public:
      nft(account_name self) : contract(self), tokens(_self, _self) {}

      void create(const yx_symbol &ysymbol, uint16_t can_set_options);

      void issue(account_name to,
                 asset quantity,
                 vector<string> uris,
                 string name,
                 string memo);

      void transferid(account_name from,
                      account_name to,
                      id_type id,
                      string memo);

      void transfer(account_name from,
                    account_name to,
                    asset quantity,
                    string memo);

      void redeem(account_name owner, id_type token_id);


      // @abi table taccounts i64
      struct account {
         yx_asset balance;

         uint64_t primary_key() const { return balance.symbol.name(); }
      };

      // @abi table tstats i64
      struct stats {
         yx_asset supply;

         uint64_t primary_key() const { return supply.symbol.name(); }

         account_name get_issuer() const { return supply.issuer; }
      };

      // @abi table tokens i64
      struct token {
         id_type id;          // Unique 64 bit identifier,
         uri_type uri;        // RFC 3986
         account_name owner;  // token owner
         yx_asset value;      // token value (1 XXX)
         string name;         // token name

         id_type primary_key() const { return id; }

         account_name get_owner() const { return owner; }

         string get_uri() const { return uri; }

         asset get_value() const { return value; }

         uint64_t get_symbol() const { return value.symbol.name(); }

         uint64_t get_name() const { return string_to_name(name.c_str()); }

         uuid get_global_id() const {
            uint128_t self_128 = static_cast<uint128_t>(N(_self));
            uint128_t id_128 = static_cast<uint128_t>(id);
            uint128_t res = (self_128 << 64) | (id_128);
            return res;
         }

         string get_unique_name() const {
            string unique_name = name + "#" + std::to_string(id);
            return unique_name;
         }
      };

      using accounts_index = eosio::multi_index<N(taccounts), account>;

      using stats_index = eosio::multi_index<N(tstats), stats,
            indexed_by<N(byissuer), const_mem_fun<stats, account_name, &stats::get_issuer> > >;

      using token_index = eosio::multi_index<N(token), token,
            indexed_by<N(byowner), const_mem_fun<token, account_name, &token::get_owner> >,
            indexed_by<N(bysymbol), const_mem_fun<token, uint64_t, &token::get_symbol> >,
            indexed_by<N(byname), const_mem_fun<token, uint64_t, &token::get_name> > >;

   private:
      token_index tokens;

      void mint(account_name owner, account_name ram_payer, asset value, string uri, string name);

      void sub_balance(account_name owner, asset value);

      void add_balance(account_name owner, asset value, account_name ram_payer);

      void sub_supply(asset quantity);

      void add_supply(asset quantity);
   };

} /// namespace eosio
